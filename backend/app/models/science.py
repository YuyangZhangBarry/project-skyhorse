from __future__ import annotations

from datetime import date, datetime, timezone
from typing import List, Optional

from sqlalchemy import Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class DailyScience(Base):
    """每日科普：一条概念/理论/猜想，每日更新."""
    __tablename__ = "daily_science"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    date: Mapped[date] = mapped_column(Date, unique=True, nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    comments: Mapped[List["ScienceComment"]] = relationship(
        "ScienceComment",
        back_populates="science",
        order_by="ScienceComment.created_at",
    )


class ScienceComment(Base):
    """科普讨论区评论；可为登录用户或游客（guest_id 格式 游客_xxx）."""
    __tablename__ = "science_comments"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    science_date: Mapped[date] = mapped_column(Date, ForeignKey("daily_science.date"), nullable=False, index=True)
    user_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    guest_id: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)  # e.g. 游客_abc123
    content: Mapped[str] = mapped_column(Text, nullable=False)
    parent_id: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey("science_comments.id"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    science: Mapped["DailyScience"] = relationship("DailyScience", back_populates="comments")
    user = relationship("User", lazy="selectin")
    parent = relationship("ScienceComment", remote_side="ScienceComment.id", backref="replies")
