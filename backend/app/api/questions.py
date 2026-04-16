from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from app.api.schemas import (
    ChoiceOptionStatResponse,
    ChoiceStatsResponse,
    QuestionListResponse,
    QuestionResponse,
)
from app.core.database import get_db
from app.models.answer import UserAnswer
from app.models.question import ChoiceOption, Question

router = APIRouter(prefix="/api/questions", tags=["questions"])


@router.get("", response_model=QuestionListResponse)
def list_questions(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    category: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List questions with pagination and optional category/search filter."""
    query = db.query(Question)
    if category:
        query = query.filter(Question.category == category)
    if search:
        pattern = f"%{search}%"
        query = query.filter(
            or_(
                Question.title.ilike(pattern),
                Question.description.ilike(pattern),
            )
        )

    total = query.count()
    items = query.offset((page - 1) * per_page).limit(per_page).all()

    return QuestionListResponse(
        items=[QuestionResponse.model_validate(q) for q in items],
        total=total,
        page=page,
        per_page=per_page,
    )


@router.get("/{question_id}/choice-stats", response_model=ChoiceStatsResponse)
def get_choice_stats(question_id: int, db: Session = Depends(get_db)):
    """Get vote count and percentage per option for a choice question."""
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
    if question.type != "choice":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Not a choice question",
        )

    options = db.query(ChoiceOption).filter(ChoiceOption.question_id == question_id).order_by(ChoiceOption.id).all()
    total = (
        db.query(func.count(UserAnswer.id))
        .filter(
            UserAnswer.question_id == question_id,
            UserAnswer.answer_type == "choice",
        )
        .scalar()
        or 0
    )

    items: List[ChoiceOptionStatResponse] = []
    for opt in options:
        count = (
            db.query(func.count(UserAnswer.id))
            .filter(
                UserAnswer.question_id == question_id,
                UserAnswer.answer_type == "choice",
                UserAnswer.answer_content == opt.content,
            )
            .scalar()
            or 0
        )
        percentage = round((count / total * 100.0) if total else 0.0, 1)
        items.append(
            ChoiceOptionStatResponse(
                option_id=opt.id,
                content=opt.content,
                count=count,
                percentage=percentage,
            )
        )
    return ChoiceStatsResponse(items=items)


@router.get("/{question_id}", response_model=QuestionResponse)
def get_question(question_id: int, db: Session = Depends(get_db)):
    """Get a single question with its choice options."""
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
    return QuestionResponse.model_validate(question)
