from __future__ import annotations

from datetime import datetime
from typing import List, Literal, Optional

from pydantic import BaseModel, EmailStr, Field


# ── Choice Options ──────────────────────────────────────────────────────────

class ChoiceOptionResponse(BaseModel):
    id: int
    question_id: int
    content: str
    is_interesting: bool
    ai_comment: Optional[str] = None

    model_config = {"from_attributes": True}


# ── Questions ───────────────────────────────────────────────────────────────

class QuestionResponse(BaseModel):
    id: int
    title: str
    description: str
    type: str
    category: str
    difficulty: int
    is_free: bool
    metadata_: Optional[dict] = Field(None, alias="metadata_")
    options: List[ChoiceOptionResponse] = []

    model_config = {"from_attributes": True, "populate_by_name": True}


class QuestionListResponse(BaseModel):
    items: List[QuestionResponse]
    total: int
    page: int
    per_page: int


class ChoiceOptionStatResponse(BaseModel):
    option_id: int
    content: str
    count: int
    percentage: float


class ChoiceStatsResponse(BaseModel):
    items: List[ChoiceOptionStatResponse]


# ── Answers ─────────────────────────────────────────────────────────────────

class AnswerSubmitRequest(BaseModel):
    question_id: int
    answer_type: Literal["choice", "short_answer"]
    answer_content: str


class AnswerResponse(BaseModel):
    id: str
    user_id: str
    question_id: int
    answer_type: str
    answer_content: str
    ai_score: Optional[float] = None
    ai_feedback: Optional[str] = None
    imagination_score: Optional[float] = None
    logic_score: Optional[float] = None
    knowledge_score: Optional[float] = None
    creativity_score: Optional[float] = None
    scoring_status: str
    answered_at: datetime

    model_config = {"from_attributes": True}


# ── Users / Auth ────────────────────────────────────────────────────────────

class UserRegisterRequest(BaseModel):
    nickname: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=6)


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: str
    nickname: str
    email: str
    avatar_url: Optional[str] = None
    tier: str
    created_at: datetime

    model_config = {"from_attributes": True}


class StatsResponse(BaseModel):
    total_answers: int
    average_score: Optional[float]


# ── User Questions (Submissions) ────────────────────────────────────────────

class QuestionSubmitRequest(BaseModel):
    title: str = Field(..., min_length=5, max_length=500)
    description: str = Field(..., min_length=10)
    category: str


class UserQuestionResponse(BaseModel):
    id: int
    user_id: str
    title: str
    description: str
    category: str
    status: str
    created_at: datetime
    reviewed_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


# ── Forum ───────────────────────────────────────────────────────────────────

class ForumPostCreateRequest(BaseModel):
    answer_id: str
    content: str = Field(..., min_length=1)


class ForumPostResponse(BaseModel):
    id: str
    user_id: str
    user_nickname: str
    answer_id: str
    question_title: str
    content: str
    like_count: int
    liked_by_me: bool
    created_at: datetime
    selected_option: Optional[str] = None  # for choice: the option text the user chose

    model_config = {"from_attributes": True}


class ForumPostListResponse(BaseModel):
    items: List[ForumPostResponse]
    total: int
    page: int
    per_page: int


class ForumQuestionSummaryResponse(BaseModel):
    """Question with count of forum posts (for grouping the forum by question)."""
    question_id: int
    question_title: str
    post_count: int
