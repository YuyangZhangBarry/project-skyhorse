"""Seed the database with questions from questions.json and default 今日科普."""
from __future__ import annotations

import json
import sys
from datetime import date, timedelta
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.config import settings
from app.core.database import Base, engine, SessionLocal
from app.models.question import ChoiceOption, Question, QuestionType
from app.models.science import DailyScience


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

        # 今日科普：默认条目（当天 + 4 条往期）
        today = date.today()
        default_sciences = [
            (
                today,
                "缸中之脑",
                "\u201c缸中之脑\u201d是知识论中的一个思想实验，由哲学家希拉里·普特南在《理性、真理与历史》中提出。"
                "想象你的大脑被取出，放入装有营养液的缸中，由超级计算机向它输送与真实世界完全一致的神经信号。"
                "那么，你如何区分自己是在缸中，还是正过着正常的生活？这一猜想与笛卡尔的恶魔、庄周梦蝶等命题类似，"
                "探讨的是：我们能否确知外部世界的存在，还是仅仅在经验着某种\u201c模拟\u201d。"
                "它常被用来讨论怀疑论、实在论与虚拟现实伦理。",
            ),
            (
                today - timedelta(days=1),
                "薛定谔的猫",
                "\u201c薛定谔的猫\u201d是量子力学中的著名思想实验，由埃尔温·薛定谔在 1935 年提出。"
                "设想把一只猫与一个会随机衰变并释放毒气的装置同置于密闭箱中，在打开箱子观测之前，"
                "根据量子叠加态，猫应处于\u201c既死又活\u201d的叠加状态。这一悖论揭示了微观量子态与宏观经验之间的张力，"
                "常被用来讨论测量问题、多世界诠释与\u201c观察者\u201d在量子理论中的角色。",
            ),
            (
                today - timedelta(days=2),
                "费米悖论",
                "费米悖论由物理学家恩里科·费米提出，可概括为：宇宙如此古老而广阔，理论上应有大量地外文明，"
                "但为何我们至今没有观测到任何证据（\u201c他们都在哪儿？\u201d）。"
                "可能的解释包括：文明在达到星际通信能力前自我毁灭、我们尚未掌握正确的探测方式、"
                "或存在\u201c大过滤器\u201d使生命/智慧极为罕见。它推动了对生命起源、技术文明寿命与搜寻地外智慧（SETI）的思考。",
            ),
            (
                today - timedelta(days=3),
                "奥卡姆剃刀",
                "奥卡姆剃刀（Occam's Razor）是一条经典思维原则，常表述为\u201c如无必要，勿增实体\u201d。"
                "其思想可追溯至中世纪哲学家奥卡姆的威廉：在能解释现象的前提下，应优先选择假设更少、更简单的理论。"
                "它并非断言简单一定为真，而是强调在竞争理论中，更简洁者通常更易检验、更少牵强。"
                "在科学、哲学与日常决策中常被用作启发式原则。",
            ),
            (
                today - timedelta(days=4),
                "图灵测试",
                "图灵测试由艾伦·图灵在 1950 年提出，用于衡量机器是否表现出与人类无异的智能。"
                "基本设定：一位评判通过文字与另一侧的\u201c人\u201d和\u201c机器\u201d对话，若无法可靠区分二者，则称该机器通过测试。"
                "它不定义\u201c智能\u201d本身，而是从行为与可观测效果出发，对人工智能的发展与伦理讨论影响深远；"
                "同时也有批评认为，通过测试未必等同于\u201c理解\u201d或\u201c意识\u201d。",
            ),
        ]
        for d, title, content in default_sciences:
            if not db.query(DailyScience).filter(DailyScience.date == d).first():
                db.add(DailyScience(date=d, title=title, content=content))
                print(f"  Daily science seeded: {d.isoformat()} — {title}")

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
