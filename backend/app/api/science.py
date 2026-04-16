"""今日科普 API：每日一条概念/理论/猜想，带讨论区；游客可发评论（唯一可发处）。"""
from __future__ import annotations

from datetime import date, datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, Header, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.api.schemas import (
    DailyScienceResponse,
    ScienceArchiveItemResponse,
    ScienceCommentCreateRequest,
    ScienceCommentResponse,
)
from app.core.config import settings
from app.core.database import get_db
from app.models.science import DailyScience, ScienceComment
from app.models.user import User

router = APIRouter(prefix="/api/science", tags=["science"])


def _optional_user_id(authorization: Optional[str], db: Session) -> Optional[str]:
    if not authorization:
        return None
    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        return None
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id = payload.get("sub")
        if user_id and db.query(User).filter(User.id == user_id).first():
            return user_id
    except JWTError:
        pass
    return None


def _parse_date(date_str: str) -> date:
    try:
        return date.fromisoformat(date_str)
    except ValueError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid date format (use YYYY-MM-DD)")


@router.get("/today", response_model=DailyScienceResponse)
def get_today(db: Session = Depends(get_db)):
    """当天科普；若当天无则返回最近一条（视为“今日”）."""
    today = date.today()
    row = db.query(DailyScience).filter(DailyScience.date <= today).order_by(DailyScience.date.desc()).first()
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No science entry found")
    return DailyScienceResponse(
        date=row.date.isoformat(),
        title=row.title,
        content=row.content,
    )


@router.get("/archive", response_model=List[ScienceArchiveItemResponse])
def list_archive(db: Session = Depends(get_db)):
    """往期科普列表，按日期倒序."""
    rows = db.query(DailyScience).order_by(DailyScience.date.desc()).all()
    return [ScienceArchiveItemResponse(date=r.date.isoformat(), title=r.title) for r in rows]


@router.get("/{date_str}", response_model=dict)
def get_by_date(
    date_str: str,
    db: Session = Depends(get_db),
):
    """指定日期的科普全文 + 评论列表（往期仅可读，不可发评论）。"""
    d = _parse_date(date_str)
    row = db.query(DailyScience).filter(DailyScience.date == d).first()
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")
    comments: List[ScienceCommentResponse] = []
    for c in row.comments:
        if c.user_id and c.user:
            author_label = c.user.nickname
            is_guest = False
        else:
            author_label = c.guest_id or "游客"
            is_guest = True
        comments.append(
            ScienceCommentResponse(
                id=c.id,
                author_label=author_label,
                content=c.content,
                created_at=c.created_at,
                is_guest=is_guest,
            )
        )
    return {
        "date": row.date.isoformat(),
        "title": row.title,
        "content": row.content,
        "comments": comments,
        "is_today": row.date == date.today(),
    }


@router.post("/{date_str}/comments", status_code=status.HTTP_201_CREATED)
def create_comment(
    date_str: str,
    body: ScienceCommentCreateRequest,
    db: Session = Depends(get_db),
    authorization: Optional[str] = Header(None, alias="Authorization"),
):
    """发表评论。仅当 date 为当天时可发；未登录时须传 guest_id（格式 游客_xxx）。"""
    d = _parse_date(date_str)
    if d != date.today():
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="只能对当日科普发表评论")
    science = db.query(DailyScience).filter(DailyScience.date == d).first()
    if not science:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")

    user_id = _optional_user_id(authorization, db)
    guest_id: Optional[str] = None
    if user_id:
        guest_id = None
    else:
        guest_id = (body.guest_id or "").strip()
        if not guest_id or not guest_id.startswith("游客"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="游客发表时请提供 guest_id，格式：游客_随机id",
            )

    comment = ScienceComment(
        science_date=d,
        user_id=user_id,
        guest_id=guest_id if guest_id else None,
        content=body.content.strip(),
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return {
        "id": comment.id,
        "author_label": comment.user.nickname if comment.user else (comment.guest_id or "游客"),
        "content": comment.content,
        "created_at": comment.created_at,
        "is_guest": comment.guest_id is not None,
    }
