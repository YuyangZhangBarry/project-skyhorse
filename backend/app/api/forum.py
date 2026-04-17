from __future__ import annotations

from typing import List, Optional

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Request, status
from jose import JWTError, jwt
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.api.schemas import (
    ForumPostCreateRequest,
    ForumPostListResponse,
    ForumPostResponse,
    ForumQuestionSummaryResponse,
)
from app.core.config import settings
from app.core.database import get_db
from app.core.i18n import get_lang, pick
from app.core.security import get_current_user
from app.models.answer import UserAnswer
from app.models.forum import ForumLike, ForumPost
from app.models.question import ChoiceOption, Question
from app.models.user import User

router = APIRouter(prefix="/api/forum", tags=["forum"])


def _localized_selected_option(
    db: Session,
    question: Optional[Question],
    answer: Optional[UserAnswer],
    lang: str,
) -> Optional[str]:
    """For choice questions, return option text in the requested language; else raw answer text."""
    if not question or not answer:
        return None
    if question.type != "choice":
        return answer.answer_content
    opt = (
        db.query(ChoiceOption)
        .filter(
            ChoiceOption.question_id == question.id,
            or_(
                ChoiceOption.content == answer.answer_content,
                ChoiceOption.content_en == answer.answer_content,
            ),
        )
        .first()
    )
    if not opt:
        return answer.answer_content
    return pick(opt.content, opt.content_en, lang)


def _resolve_optional_user_id(authorization: Optional[str], db: Session) -> Optional[str]:
    """Extract user_id from an Authorization header, returning None when absent/invalid."""
    if not authorization:
        return None
    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        return None
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: Optional[str] = payload.get("sub")
        if user_id and db.query(User).filter(User.id == user_id).first():
            return user_id
    except JWTError:
        pass
    return None


@router.post("", response_model=ForumPostResponse, status_code=status.HTTP_201_CREATED)
def create_post(
    request: Request,
    body: ForumPostCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a forum post. Must reference one of your own answers."""
    answer = (
        db.query(UserAnswer)
        .filter(UserAnswer.id == body.answer_id, UserAnswer.user_id == current_user.id)
        .first()
    )
    if not answer:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Answer not found or does not belong to you",
        )

    post = ForumPost(
        user_id=current_user.id,
        answer_id=body.answer_id,
        content=body.content,
    )
    db.add(post)
    db.commit()
    db.refresh(post)

    question = db.query(Question).filter(Question.id == answer.question_id).first()
    lang = get_lang(request)

    return ForumPostResponse(
        id=post.id,
        user_id=post.user_id,
        user_nickname=current_user.nickname,
        answer_id=post.answer_id,
        question_title=pick(question.title, question.title_en, lang) if question else "",
        content=post.content,
        like_count=0,
        liked_by_me=False,
        created_at=post.created_at,
        selected_option=_localized_selected_option(db, question, answer, lang),
    )


@router.get("/questions", response_model=List[ForumQuestionSummaryResponse])
def list_questions_with_posts(request: Request, db: Session = Depends(get_db)):
    """List questions that have at least one forum post, with post count (for grouping the forum)."""
    lang = get_lang(request)
    rows = (
        db.query(Question.id, Question.title, Question.title_en, func.count(ForumPost.id).label("post_count"))
        .join(UserAnswer, UserAnswer.question_id == Question.id)
        .join(ForumPost, ForumPost.answer_id == UserAnswer.id)
        .group_by(Question.id, Question.title, Question.title_en)
        .order_by(func.count(ForumPost.id).desc())
        .all()
    )
    return [
        ForumQuestionSummaryResponse(
            question_id=row.id,
            question_title=pick(row.title, row.title_en, lang),
            post_count=row.post_count,
        )
        for row in rows
    ]


@router.get("", response_model=ForumPostListResponse)
def list_posts(
    request: Request,
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    question_id: Optional[int] = Query(None),
    sort: Optional[str] = Query("likes", description="likes = by like count desc, time = by newest first"),
    authorization: Optional[str] = Header(None, alias="Authorization"),
    db: Session = Depends(get_db),
):
    """List forum posts with pagination. Supports optional auth for liked_by_me. Sort: likes (default) or time."""
    lang = get_lang(request)
    current_user_id = _resolve_optional_user_id(authorization, db)

    query = db.query(ForumPost)
    if question_id is not None:
        query = query.join(UserAnswer, ForumPost.answer_id == UserAnswer.id).filter(
            UserAnswer.question_id == question_id
        )

    total = query.count()

    if sort == "time":
        posts = query.order_by(ForumPost.created_at.desc()).offset((page - 1) * per_page).limit(per_page).all()
    else:
        like_subq = (
            db.query(ForumLike.post_id, func.count(ForumLike.id).label("like_count"))
            .group_by(ForumLike.post_id)
            .subquery()
        )
        posts = (
            query.outerjoin(like_subq, ForumPost.id == like_subq.c.post_id)
            .order_by(like_subq.c.like_count.desc().nulls_last(), ForumPost.created_at.desc())
            .offset((page - 1) * per_page)
            .limit(per_page)
            .all()
        )

    liked_post_ids: set = set()
    if current_user_id and posts:
        post_ids = [p.id for p in posts]
        liked_rows = (
            db.query(ForumLike.post_id)
            .filter(ForumLike.post_id.in_(post_ids), ForumLike.user_id == current_user_id)
            .all()
        )
        liked_post_ids = {row[0] for row in liked_rows}

    items = []
    for post in posts:
        like_count = db.query(func.count(ForumLike.id)).filter(ForumLike.post_id == post.id).scalar() or 0
        user = post.user
        answer = post.answer
        question = db.query(Question).filter(Question.id == answer.question_id).first() if answer else None

        items.append(ForumPostResponse(
            id=post.id,
            user_id=post.user_id,
            user_nickname=user.nickname if user else "",
            answer_id=post.answer_id,
            question_title=pick(question.title, question.title_en, lang) if question else "",
            content=post.content,
            like_count=like_count,
            liked_by_me=post.id in liked_post_ids,
            created_at=post.created_at,
            selected_option=_localized_selected_option(db, question, answer, lang),
        ))

    return ForumPostListResponse(items=items, total=total, page=page, per_page=per_page)


@router.post("/{post_id}/like")
def toggle_like(
    post_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Toggle like on a forum post. Returns new like_count."""
    post = db.query(ForumPost).filter(ForumPost.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    existing = (
        db.query(ForumLike)
        .filter(ForumLike.post_id == post_id, ForumLike.user_id == current_user.id)
        .first()
    )
    if existing:
        db.delete(existing)
    else:
        db.add(ForumLike(post_id=post_id, user_id=current_user.id))
    db.commit()

    like_count = db.query(func.count(ForumLike.id)).filter(ForumLike.post_id == post_id).scalar() or 0
    return {"like_count": like_count}
