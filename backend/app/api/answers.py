import threading
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.api.schemas import AnswerResponse, AnswerSubmitRequest
from app.core.database import get_db
from app.core.i18n import get_lang, pick
from app.core.security import get_current_user
from app.models.answer import AnswerType, ScoringStatus, UserAnswer
from app.models.question import ChoiceOption, Question
from app.models.user import User

router = APIRouter(prefix="/api/answers", tags=["answers"])


@router.post("", response_model=AnswerResponse, status_code=status.HTTP_201_CREATED)
def submit_answer(
    request: Request,
    body: AnswerSubmitRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Submit an answer. Choice answers return immediately; short answers trigger AI scoring."""
    question = db.query(Question).filter(Question.id == body.question_id).first()
    if not question:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")

    answer = UserAnswer(
        user_id=current_user.id,
        question_id=body.question_id,
        answer_type=body.answer_type,
        answer_content=body.answer_content,
    )

    if body.answer_type == AnswerType.choice:
        option = (
            db.query(ChoiceOption)
            .filter(
                ChoiceOption.question_id == body.question_id,
                or_(
                    ChoiceOption.content == body.answer_content,
                    ChoiceOption.content_en == body.answer_content,
                ),
            )
            .first()
        )
        if option:
            answer.answer_content = option.content
            lang = get_lang(request)
            comment = pick(option.ai_comment or "", option.ai_comment_en, lang)
            if comment:
                answer.ai_feedback = comment
        answer.scoring_status = ScoringStatus.completed
    else:
        answer.scoring_status = ScoringStatus.scoring

    db.add(answer)
    db.commit()
    db.refresh(answer)

    if body.answer_type == AnswerType.short_answer:
        from app.tasks.scoring import score_answer_task

        lang = get_lang(request)
        thread = threading.Thread(target=score_answer_task, args=(str(answer.id), lang))
        thread.start()

    return AnswerResponse.model_validate(answer)


@router.get("/history", response_model=List[AnswerResponse])
def get_answer_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get the current user's answer history."""
    answers = (
        db.query(UserAnswer)
        .filter(UserAnswer.user_id == current_user.id)
        .order_by(UserAnswer.answered_at.desc())
        .all()
    )
    return [AnswerResponse.model_validate(a) for a in answers]


@router.get("/{answer_id}", response_model=AnswerResponse)
def get_answer(
    answer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific answer result (poll for scoring status)."""
    answer = (
        db.query(UserAnswer)
        .filter(UserAnswer.id == answer_id, UserAnswer.user_id == current_user.id)
        .first()
    )
    if not answer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Answer not found")
    return AnswerResponse.model_validate(answer)
