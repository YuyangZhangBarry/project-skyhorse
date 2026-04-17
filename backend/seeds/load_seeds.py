"""Seed the database with questions from questions.json and default 今日科普."""
from __future__ import annotations

import json
import sys
from datetime import date
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
    from app.models.forum import ForumLike, ForumPost  # noqa: F401 – register model
    from app.models.science import DailyScience, ScienceComment  # noqa: F401 – register model
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
                title_en=q_data.get("title_en"),
                description=q_data["description"],
                description_en=q_data.get("description_en"),
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
                    content_en=opt_data.get("content_en"),
                    is_interesting=opt_data.get("is_interesting", False),
                    ai_comment=opt_data.get("ai_comment"),
                    ai_comment_en=opt_data.get("ai_comment_en"),
                )
                db.add(option)
                created_options += 1

            created_questions += 1
            print(f"  [{idx}/{len(questions_data)}] ADD: {q_data['title'][:40]}... ({len(options)} options)")

        # 今日科普：仅从 sciences.json 按日历日轮换；每次只补「今天」缺失的一条，往期随日期自然累积。
        sciences_path = Path(__file__).resolve().parent / "sciences.json"
        if not sciences_path.exists():
            print(f"  WARNING: {sciences_path} not found, skipping daily science seed")
        else:
            with open(sciences_path, encoding="utf-8") as sf:
                science_pool: list = json.load(sf)
            if not science_pool:
                print("  WARNING: sciences.json is empty, skipping daily science seed")
            else:
                n = len(science_pool)
                today = date.today()
                if not db.query(DailyScience).filter(DailyScience.date == today).first():
                    idx = today.toordinal() % n
                    entry = science_pool[idx]
                    db.add(
                        DailyScience(
                            date=today,
                            title=entry["title"],
                            content=entry["content"],
                            title_en=entry.get("title_en"),
                            content_en=entry.get("content_en"),
                        )
                    )
                    print(f"  Daily science seeded: {today.isoformat()} — {entry['title']} (pool[{idx}])")
                else:
                    print(f"  Daily science: {today.isoformat()} already present, skip")

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
