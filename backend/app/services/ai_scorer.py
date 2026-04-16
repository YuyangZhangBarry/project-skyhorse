import hashlib
import json
import logging
import re
import time
from abc import ABC, abstractmethod

from app.core.config import settings

logger = logging.getLogger(__name__)

SCORING_PROMPT = """你是"天马行空问答"的AI评分官。请对用户的回答从以下四个维度打分，每个维度0-25分：

1. 想象力 (imagination): 回答是否展现了丰富的想象力和创造性思维？
2. 逻辑性 (logic): 回答是否逻辑清晰、论证合理？
3. 知识面 (knowledge): 回答是否体现了广泛或深入的知识？
4. 趣味性 (creativity): 回答是否有趣、引人入胜？

题目: {title}
题目描述: {description}
用户回答: {answer}

请以JSON格式返回评分结果，不要包含任何其他文字：
{{
  "total_score": <四项总分>,
  "imagination": <想象力得分>,
  "logic": <逻辑性得分>,
  "knowledge": <知识面得分>,
  "creativity": <趣味性得分>,
  "feedback": "<中文评语，100字以内>"
}}"""

SCORING_PROMPT_EN = """You are the AI scorer for "Skyhorse Q&A". Score the user's answer on four dimensions (0-25 each):

1. Imagination: Does it show creative thinking?
2. Logic: Is it logically clear and well-reasoned?
3. Knowledge: Does it reflect broad or deep knowledge?
4. Fun: Is it interesting and engaging?

Question: {title}
Description: {description}
User's answer: {answer}

Return ONLY JSON, no other text:
{{
  "total_score": <sum of four>,
  "imagination": <score>,
  "logic": <score>,
  "knowledge": <score>,
  "creativity": <score>,
  "feedback": "<English feedback, under 100 words>"
}}"""


class AIScorer(ABC):
    @abstractmethod
    def score(self, question_title: str, question_description: str, user_answer: str, lang: str = "zh") -> dict:
        ...


class LocalScorer(AIScorer):
    """Text-analysis scorer that runs locally without any API key."""

    LOGIC_WORDS = set("因为|所以|但是|然而|如果|那么|首先|其次|最后|总之|"
                      "因此|由于|虽然|不过|另外|同时|而且|也就是说|换句话说|"
                      "一方面|另一方面|综上|可见|假设|推测|可能|必然".split("|"))

    KNOWLEDGE_WORDS = set("科学|物理|化学|生物|历史|数学|宇宙|量子|进化|"
                          "哲学|心理|经济|社会|技术|基因|相对论|熵|光速|"
                          "引力|时空|文明|理论|实验|研究|数据|能量|原子|"
                          "星球|银河|维度|概率|算法|神经|细胞|DNA|光合作用".split("|"))

    IMAGINATION_WORDS = set("想象|假如|如果|万一|也许|或许|幻想|梦|穿越|"
                            "未来|可能性|平行|异世界|超能力|变成|突然|奇妙|"
                            "脑洞|创意|灵感|颠覆|打破|重新定义|不可思议".split("|"))

    LOGIC_WORDS_EN = set("because|therefore|however|if|then|first|moreover|"
                         "consequently|although|furthermore|meanwhile|hence|"
                         "assuming|possibly".split("|"))

    KNOWLEDGE_WORDS_EN = set("science|physics|chemistry|biology|history|math|"
                             "universe|quantum|evolution|philosophy|psychology|"
                             "technology|theory|experiment|research|energy|"
                             "atom|galaxy|algorithm|neural|DNA".split("|"))

    IMAGINATION_WORDS_EN = set("imagine|what if|perhaps|maybe|fantasy|dream|"
                               "future|possibility|parallel|superpower|"
                               "suddenly|amazing|creative|inspiration|redefine|"
                               "incredible".split("|"))

    FEEDBACK_TEMPLATES = [
        ("精彩", "你的回答展现了很强的{dim}！论述有理有据，同时不乏想象力。如果能更多地结合具体例子，会更加出色。"),
        ("有深度", "很有深度的思考！你在{dim}方面表现突出。建议可以尝试从更多角度来看待这个问题，会有更丰富的收获。"),
        ("独到", "你的视角很独到，{dim}令人印象深刻。如果能进一步展开论述，让逻辑链更完整，分数还能更高！"),
        ("不错", "不错的回答！{dim}有一定水准。可以试着挑战自己，加入更大胆的想象或更严谨的推理，让回答更上一层楼。"),
        ("有潜力", "看得出你对这个话题有兴趣！{dim}还有提升空间。建议多阅读相关领域的内容，下次一定能写出更精彩的回答。"),
    ]

    FEEDBACK_TEMPLATES_EN = [
        ("Excellent", "Your answer shows strong {dim}! Well-argued with great imagination. Adding specific examples would make it even better."),
        ("Insightful", "Very thoughtful! You stand out in {dim}. Try exploring more angles for an even richer perspective."),
        ("Unique", "Your perspective is unique, and your {dim} is impressive. Expanding your reasoning could push your score higher!"),
        ("Solid", "A solid answer! Your {dim} is quite good. Challenge yourself with bolder ideas or tighter logic to level up."),
        ("Promising", "You clearly find this topic interesting! There's room to grow in {dim}. More reading will help you shine next time."),
    ]

    def _count_keyword_hits(self, text: str, word_set: set) -> int:
        return sum(1 for w in word_set if w in text)

    def _unique_chars(self, text: str) -> int:
        return len(set(text))

    def _sentence_count(self, text: str) -> int:
        return max(1, len(re.split(r'[。！？.!?\n]', text)))

    def _deterministic_jitter(self, seed_text: str, dimension: str) -> float:
        h = hashlib.md5(f"{seed_text}:{dimension}".encode()).hexdigest()
        return (int(h[:8], 16) % 100) / 100.0 * 3 - 1.5

    def score(self, question_title: str, question_description: str, user_answer: str, lang: str = "zh") -> dict:
        time.sleep(1.5)

        en = lang == "en"
        imag_words = self.IMAGINATION_WORDS_EN if en else self.IMAGINATION_WORDS
        logic_words = self.LOGIC_WORDS_EN if en else self.LOGIC_WORDS
        know_words = self.KNOWLEDGE_WORDS_EN if en else self.KNOWLEDGE_WORDS
        templates = self.FEEDBACK_TEMPLATES_EN if en else self.FEEDBACK_TEMPLATES

        length = len(user_answer)
        sentences = self._sentence_count(user_answer)
        unique = self._unique_chars(user_answer)
        combined = question_title + question_description + user_answer

        length_factor = min(1.0, length / 200)
        diversity_factor = min(1.0, unique / max(1, length) * 3)

        imag_hits = self._count_keyword_hits(combined, imag_words)
        imagination = 10 + length_factor * 5 + min(imag_hits, 5) * 1.5 + diversity_factor * 2
        imagination += self._deterministic_jitter(user_answer, "imag")
        imagination = max(5, min(25, imagination))

        logic_hits = self._count_keyword_hits(combined, logic_words)
        sentence_factor = min(1.0, sentences / 5)
        logic = 10 + sentence_factor * 5 + min(logic_hits, 6) * 1.5 + length_factor * 2
        logic += self._deterministic_jitter(user_answer, "logic")
        logic = max(5, min(25, logic))

        know_hits = self._count_keyword_hits(combined, know_words)
        knowledge = 8 + min(know_hits, 8) * 1.8 + length_factor * 3 + diversity_factor * 2
        knowledge += self._deterministic_jitter(user_answer, "know")
        knowledge = max(5, min(25, knowledge))

        creativity = 10 + diversity_factor * 5 + length_factor * 3 + min(imag_hits, 3) * 1.5
        has_question = "？" in user_answer or "?" in user_answer
        if en:
            has_metaphor = any(w in user_answer for w in ["like", "as if", "similar to", "just as", "resembles"])
        else:
            has_metaphor = any(w in user_answer for w in ["就像", "好比", "仿佛", "如同", "类似"])
        creativity += 2 if has_question else 0
        creativity += 2 if has_metaphor else 0
        creativity += self._deterministic_jitter(user_answer, "crea")
        creativity = max(5, min(25, creativity))

        imagination = round(imagination, 1)
        logic = round(logic, 1)
        knowledge = round(knowledge, 1)
        creativity = round(creativity, 1)
        total = round(imagination + logic + knowledge + creativity, 1)

        if en:
            dims = {"Imagination": imagination, "Logic": logic, "Knowledge": knowledge, "Fun": creativity}
        else:
            dims = {"想象力": imagination, "逻辑性": logic, "知识面": knowledge, "趣味性": creativity}
        best_dim = max(dims, key=dims.get)
        idx = int(hashlib.md5(user_answer.encode()).hexdigest()[:8], 16) % len(templates)
        _, template = templates[idx]
        feedback = template.format(dim=best_dim)

        return {
            "total_score": total,
            "imagination": imagination,
            "logic": logic,
            "knowledge": knowledge,
            "creativity": creativity,
            "feedback": feedback,
        }


class DeepSeekScorer(AIScorer):
    def __init__(self):
        from openai import OpenAI
        self.client = OpenAI(
            api_key=settings.DEEPSEEK_API_KEY,
            base_url=settings.DEEPSEEK_BASE_URL,
        )

    def score(self, question_title: str, question_description: str, user_answer: str, lang: str = "zh") -> dict:
        tpl = SCORING_PROMPT_EN if lang == "en" else SCORING_PROMPT
        prompt = tpl.format(
            title=question_title,
            description=question_description,
            answer=user_answer,
        )
        response = self.client.chat.completions.create(
            model="deepseek-chat",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        return json.loads(content)


class OpenAIScorer(AIScorer):
    def __init__(self):
        from openai import OpenAI
        self.client = OpenAI(
            api_key=settings.OPENAI_API_KEY,
            base_url=settings.OPENAI_BASE_URL,
        )

    def score(self, question_title: str, question_description: str, user_answer: str, lang: str = "zh") -> dict:
        tpl = SCORING_PROMPT_EN if lang == "en" else SCORING_PROMPT
        prompt = tpl.format(
            title=question_title,
            description=question_description,
            answer=user_answer,
        )
        response = self.client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        return json.loads(content)


def get_scorer() -> AIScorer:
    provider = settings.AI_PROVIDER.lower()
    if provider == "openai":
        return OpenAIScorer()
    if provider == "deepseek":
        return DeepSeekScorer()
    logger.info("Using local text-analysis scorer (no API key required)")
    return LocalScorer()
