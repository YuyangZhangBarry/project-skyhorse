import enum
from typing import List, Optional

from sqlalchemy import Boolean, ForeignKey, Integer, JSON, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class QuestionType(str, enum.Enum):
    choice = "choice"
    short_answer = "short_answer"


class Question(Base):
    __tablename__ = "questions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(500))
    description: Mapped[str] = mapped_column(Text)
    type: Mapped[str] = mapped_column(String(20))
    category: Mapped[str] = mapped_column(String(100), index=True)
    difficulty: Mapped[int] = mapped_column(Integer)
    is_free: Mapped[bool] = mapped_column(Boolean, default=True)
    metadata_: Mapped[Optional[dict]] = mapped_column("metadata", JSON, nullable=True)

    options: Mapped[List["ChoiceOption"]] = relationship(back_populates="question", lazy="selectin")


class ChoiceOption(Base):
    __tablename__ = "choice_options"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    question_id: Mapped[int] = mapped_column(Integer, ForeignKey("questions.id"))
    content: Mapped[str] = mapped_column(String(1000))
    is_interesting: Mapped[bool] = mapped_column(Boolean, default=False)
    ai_comment: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    question: Mapped["Question"] = relationship(back_populates="options")
