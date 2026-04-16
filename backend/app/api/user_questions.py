from __future__ import annotations

from typing import List

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.schemas import QuestionSubmitRequest, UserQuestionResponse
from app.core.database import get_db
from app.core.security import get_current_user
from app.models.question import UserQuestion
from app.models.user import User

router = APIRouter(prefix="/api/user-questions", tags=["user-questions"])


@router.post("", response_model=UserQuestionResponse, status_code=status.HTTP_201_CREATED)
def submit_question(
    body: QuestionSubmitRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Submit a user question."""

    uq = UserQuestion(
        user_id=current_user.id,
        title=body.title,
        description=body.description,
        category=body.category,
    )
    db.add(uq)
    db.commit()
    db.refresh(uq)
    return UserQuestionResponse.model_validate(uq)


@router.get("", response_model=List[UserQuestionResponse])
def list_my_questions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List the current user's submitted questions."""
    questions = (
        db.query(UserQuestion)
        .filter(UserQuestion.user_id == current_user.id)
        .order_by(UserQuestion.created_at.desc())
        .all()
    )
    return [UserQuestionResponse.model_validate(q) for q in questions]


@router.get("/approved", response_model=List[UserQuestionResponse])
def list_approved_questions(db: Session = Depends(get_db)):
    """List all approved user questions (public, no auth needed)."""
    questions = (
        db.query(UserQuestion)
        .filter(UserQuestion.status == "approved")
        .order_by(UserQuestion.created_at.desc())
        .all()
    )
    return [UserQuestionResponse.model_validate(q) for q in questions]
