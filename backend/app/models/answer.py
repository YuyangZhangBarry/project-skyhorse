import enum
import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import DateTime, Enum, Float, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class AnswerType(str, enum.Enum):
    choice = "choice"
    short_answer = "short_answer"


class ScoringStatus(str, enum.Enum):
    pending = "pending"
    scoring = "scoring"
    completed = "completed"
    failed = "failed"


class UserAnswer(Base):
    __tablename__ = "user_answers"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"))
    question_id: Mapped[int] = mapped_column(Integer, ForeignKey("questions.id"))
    answer_type: Mapped[AnswerType] = mapped_column(Enum(AnswerType))
    answer_content: Mapped[str] = mapped_column(Text)

    ai_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    ai_feedback: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    imagination_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    logic_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    knowledge_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    creativity_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    scoring_status: Mapped[ScoringStatus] = mapped_column(
        Enum(ScoringStatus), default=ScoringStatus.pending
    )
    answered_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    user = relationship("User", lazy="selectin")
    question = relationship("Question", lazy="selectin")
