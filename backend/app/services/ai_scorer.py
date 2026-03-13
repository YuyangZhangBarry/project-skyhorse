import json
import logging
from abc import ABC, abstractmethod

from openai import OpenAI

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


class AIScorer(ABC):
    @abstractmethod
    def score(self, question_title: str, question_description: str, user_answer: str) -> dict:
        ...


class DeepSeekScorer(AIScorer):
    def __init__(self):
        self.client = OpenAI(
            api_key=settings.DEEPSEEK_API_KEY,
            base_url=settings.DEEPSEEK_BASE_URL,
        )

    def score(self, question_title: str, question_description: str, user_answer: str) -> dict:
        prompt = SCORING_PROMPT.format(
            title=question_title,
            description=question_description,
            answer=user_answer,
        )
        response = self.client.chat.completions.create(
            model="deepseek-chat",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        return json.loads(content)


class OpenAIScorer(AIScorer):
    def __init__(self):
        self.client = OpenAI(
            api_key=settings.OPENAI_API_KEY,
            base_url=settings.OPENAI_BASE_URL,
        )

    def score(self, question_title: str, question_description: str, user_answer: str) -> dict:
        prompt = SCORING_PROMPT.format(
            title=question_title,
            description=question_description,
            answer=user_answer,
        )
        response = self.client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        return json.loads(content)


def get_scorer() -> AIScorer:
    if settings.AI_PROVIDER == "openai":
        return OpenAIScorer()
    return DeepSeekScorer()
