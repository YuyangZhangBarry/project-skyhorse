from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.schemas import QuestionListResponse, QuestionResponse
from app.core.database import get_db
from app.models.question import Question

router = APIRouter(prefix="/api/questions", tags=["questions"])


@router.get("", response_model=QuestionListResponse)
def list_questions(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    category: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List questions with pagination and optional category filter."""
    query = db.query(Question)
    if category:
        query = query.filter(Question.category == category)

    total = query.count()
    items = query.offset((page - 1) * per_page).limit(per_page).all()

    return QuestionListResponse(
        items=[QuestionResponse.model_validate(q) for q in items],
        total=total,
        page=page,
        per_page=per_page,
    )


@router.get("/{question_id}", response_model=QuestionResponse)
def get_question(question_id: int, db: Session = Depends(get_db)):
    """Get a single question with its choice options."""
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
    return QuestionResponse.model_validate(question)
