"""今日科普 API：每日一条概念/理论/猜想，带讨论区。"""
from __future__ import annotations

from datetime import date, datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.schemas import (
    DailyScienceResponse,
    ScienceArchiveItemResponse,
    ScienceCommentCreateRequest,
    ScienceCommentResponse,
)
from app.core.database import get_db
from app.core.security import get_current_user
from app.models.science import DailyScience, ScienceComment
from app.models.user import User

router = APIRouter(prefix="/api/science", tags=["science"])


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
    current_user: User = Depends(get_current_user),
):
    """发表评论。仅当 date 为当天时可发；需登录。"""
    d = _parse_date(date_str)
    if d != date.today():
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="只能对当日科普发表评论")
    science = db.query(DailyScience).filter(DailyScience.date == d).first()
    if not science:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not found")

    comment = ScienceComment(
        science_date=d,
        user_id=current_user.id,
        content=body.content.strip(),
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return {
        "id": comment.id,
        "author_label": current_user.nickname,
        "content": comment.content,
        "created_at": comment.created_at,
        "is_guest": False,
    }
