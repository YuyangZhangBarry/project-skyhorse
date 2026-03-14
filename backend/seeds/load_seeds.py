"""Seed the database with questions from questions.json."""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.config import settings
from app.core.database import Base, engine, SessionLocal
from app.models.question import ChoiceOption, Question, QuestionType


def load_seeds() -> None:
    json_path = Path(__file__).resolve().parent / "questions.json"
    if not json_path.exists():
        print(f"ERROR: {json_path} not found")
        sys.exit(1)

    with open(json_path, encoding="utf-8") as f:
        questions_data = json.load(f)

    print(f"Database URL: {settings.DATABASE_URL}")
    print("Creating tables if they don't exist...")

    from app.models.answer import UserAnswer  # noqa: F401 – register model
    from app.models.user import User  # noqa: F401 – register model

    Base.metadata.create_all(bind=engine)
    print("Tables ready.")

    db = SessionLocal()
    try:
        created_questions = 0
        created_options = 0
        skipped = 0

        for idx, q_data in enumerate(questions_data, start=1):
            existing = (
                db.query(Question)
                .filter(Question.title == q_data["title"])
                .first()
            )
            if existing:
                print(f"  [{idx}/{len(questions_data)}] SKIP (exists): {q_data['title'][:40]}...")
                skipped += 1
                continue

            question = Question(
                title=q_data["title"],
                description=q_data["description"],
                type=QuestionType(q_data["type"]),
                category=q_data["category"],
                difficulty=q_data["difficulty"],
                is_free=q_data.get("is_free", True),
                metadata_=q_data.get("metadata"),
            )
            db.add(question)
            db.flush()

            options = q_data.get("options", [])
            for opt_data in options:
                option = ChoiceOption(
                    question_id=question.id,
                    content=opt_data["content"],
                    is_interesting=opt_data.get("is_interesting", False),
                    ai_comment=opt_data.get("ai_comment"),
                )
                db.add(option)
                created_options += 1

            created_questions += 1
            print(f"  [{idx}/{len(questions_data)}] ADD: {q_data['title'][:40]}... ({len(options)} options)")

        db.commit()
        print("\n--- Summary ---")
        print(f"  Questions created : {created_questions}")
        print(f"  Options created   : {created_options}")
        print(f"  Skipped (exist)   : {skipped}")
        print(f"  Total in JSON     : {len(questions_data)}")
        print("Done!")

    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    load_seeds()
