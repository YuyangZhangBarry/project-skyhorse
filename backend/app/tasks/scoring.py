import logging

from app.core.database import SessionLocal
from app.models.answer import ScoringStatus, UserAnswer
from app.services.ai_scorer import get_scorer

logger = logging.getLogger(__name__)


def score_answer_task(answer_id: str) -> None:
    """Score a user's short-answer response using the configured AI provider."""
    db = SessionLocal()
    answer = None
    try:
        answer = db.query(UserAnswer).filter(UserAnswer.id == answer_id).first()
        if answer is None:
            logger.error("Answer %s not found", answer_id)
            return

        answer.scoring_status = ScoringStatus.scoring
        db.commit()

        question = answer.question
        scorer = get_scorer()
        result = scorer.score(
            question_title=question.title,
            question_description=question.description,
            user_answer=answer.answer_content,
        )

        answer.ai_score = result.get("total_score")
        answer.imagination_score = result.get("imagination")
        answer.logic_score = result.get("logic")
        answer.knowledge_score = result.get("knowledge")
        answer.creativity_score = result.get("creativity")
        answer.ai_feedback = result.get("feedback")
        answer.scoring_status = ScoringStatus.completed
        db.commit()

        logger.info("Successfully scored answer %s: %.1f", answer_id, answer.ai_score)
    except Exception:
        logger.exception("Failed to score answer %s", answer_id)
        if answer is None:
            return
        try:
            answer.scoring_status = ScoringStatus.failed
            db.commit()
        except Exception:
            db.rollback()
    finally:
        db.close()
