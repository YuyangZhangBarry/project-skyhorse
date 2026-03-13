import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import answers, questions, users

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="天马行空问答 API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(questions.router)
app.include_router(answers.router)
app.include_router(users.router)


@app.get("/api/health", tags=["health"])
def health_check():
    return {"status": "ok"}


@app.on_event("startup")
def on_startup():
    logger.info("Skyhorse API starting...")
