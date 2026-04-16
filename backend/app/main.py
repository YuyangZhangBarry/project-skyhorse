import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import answers, forum, questions, science, user_questions, users
from app.core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Skyhorse API starting...")
    yield
    logger.info("Skyhorse API shutting down...")


app = FastAPI(title="天马行空问答 API", version="0.1.0", lifespan=lifespan)

_origins = [o.strip() for o in settings.ALLOWED_ORIGINS.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(questions.router)
app.include_router(answers.router)
app.include_router(users.router)
app.include_router(user_questions.router)
app.include_router(forum.router)
app.include_router(science.router)


@app.get("/api/health", tags=["health"])
def health_check():
    return {"status": "ok"}
