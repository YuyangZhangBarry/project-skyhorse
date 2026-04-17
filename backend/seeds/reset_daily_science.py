"""一次性清空「今日科普」及评论，只保留「今天」的一条（按 sciences.json 轮换规则）。

用法（在 backend 目录下，且已配置 DATABASE_URL / .env）:
  python seeds/reset_daily_science.py

生产环境（Neon 等）可在本地设好 DATABASE_URL 后执行，或在 Render Shell 里运行。
"""
from __future__ import annotations

import json
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from sqlalchemy import text

from app.core.database import SessionLocal
from app.models.answer import UserAnswer  # noqa: F401 — register ORM
from app.models.forum import ForumLike, ForumPost  # noqa: F401
from app.models.question import ChoiceOption, Question  # noqa: F401
from app.models.science import DailyScience
from app.models.user import User  # noqa: F401



def main() -> None:
    sciences_path = Path(__file__).resolve().parent / "sciences.json"
    if not sciences_path.exists():
        print(f"ERROR: {sciences_path} not found")
        sys.exit(1)
    with open(sciences_path, encoding="utf-8") as f:
        science_pool: list = json.load(f)
    if not science_pool:
        print("ERROR: sciences.json is empty")
        sys.exit(1)

    db = SessionLocal()
    try:
        # Raw SQL so we don't need to load all related ORM mappers (User, etc.)
        r_c = db.execute(text("DELETE FROM science_comments"))
        r_d = db.execute(text("DELETE FROM daily_science"))
        db.commit()
        print(f"Deleted science_comments rowcount={r_c.rowcount}, daily_science rowcount={r_d.rowcount}")

        today = date.today()
        n = len(science_pool)
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
        db.commit()
        print(f"Inserted today only: {today.isoformat()} — {entry['title']} (pool[{idx}])")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()
