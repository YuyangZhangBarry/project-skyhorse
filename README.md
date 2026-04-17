<div align="center">

# Project Skyhorse

**A Bilingual Creative Q&A App with AI Scoring**

[English](README.md) / [简体中文](README_zh.md)

</div>

---

**Live app:** [Open the web app](https://web-nine-psi-56.vercel.app/)

## Introduction

A bilingual (Chinese/English) creative Q&A application featuring imaginative questions, AI-powered scoring, daily science articles, and a community forum. Users answer thought-provoking questions and receive personalized AI feedback across four dimensions: Imagination, Logic, Knowledge, and Creativity.

## Features

- **Creative Questions** — Curated questions across 5 categories: Science, Philosophy, Brain Teasers, Life, and Universe
- **Dual Answer Modes** — Choice questions with vote statistics & short-answer questions with AI scoring
- **AI Scoring** — DeepSeek / OpenAI powered evaluation with personalized feedback
- **Daily Science** — A new science concept/theory every day with community discussion
- **Community Forum** — Share and discuss answers with other users
- **Bilingual Support** — Full Chinese/English toggle for UI, questions, AI feedback, and all content
- **User Profiles** — Track answer history and average scores

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3 (Web / Android / iOS) |
| **Backend** | Python 3.12 + FastAPI |
| **Database** | PostgreSQL (Neon) |
| **AI Scoring** | DeepSeek API (primary) / OpenAI (fallback) / Local scorer (offline) |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **Deployment** | Render (backend) + Vercel (frontend) |

## Project Structure

    project-skyhorse/
    ├── app/                          # Flutter frontend
    │   ├── lib/
    │   │   ├── config/               # Theme, router configuration
    │   │   ├── l10n/                 # Localization (i18n) files
    │   │   ├── models/               # Data models
    │   │   ├── providers/            # Riverpod state providers
    │   │   ├── screens/              # UI screens
    │   │   │   ├── auth/             # Login & register
    │   │   │   ├── home/             # Question list & search
    │   │   │   ├── question/         # Answer a question
    │   │   │   ├── result/           # AI scoring result
    │   │   │   ├── choice_result/    # Choice vote statistics
    │   │   │   ├── forum/            # Community forum
    │   │   │   ├── main_shell/       # Bottom nav & science pages
    │   │   │   ├── profile/          # User profile
    │   │   │   └── submit/           # Submit custom questions
    │   │   ├── services/             # API service layer
    │   │   ├── utils/                # Shared utilities
    │   │   └── widgets/              # Reusable UI components
    │   └── pubspec.yaml
    ├── backend/                      # FastAPI backend
    │   ├── app/
    │   │   ├── api/                  # Route handlers
    │   │   ├── core/                 # Config, database, security, i18n
    │   │   ├── models/               # SQLAlchemy ORM models
    │   │   ├── services/             # AI scorer engines
    │   │   └── tasks/                # Scoring task runner
    │   ├── seeds/                    # Seed data (60 bilingual questions)
    │   ├── migrations/               # Alembic database migrations
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── start.sh                  # Entrypoint: seed DB + start server
    └── README.md

## Getting Started

### Prerequisites

- **Flutter** >= 3.11
- **Python** >= 3.12
- **PostgreSQL** (or use SQLite locally)

### Backend Setup

    cd backend
    python -m venv venv
    source venv/bin/activate          # Windows: venv\Scripts\activate
    pip install -r requirements.txt
    cp .env.example .env              # Then edit .env with your config
    python seeds/load_seeds.py        # Initialize DB and seed data
    uvicorn app.main:app --reload --port 8000

The API will be available at http://localhost:8000. Health check: `GET /api/health`.

### Frontend Setup

    cd app
    flutter pub get
    flutter run -d chrome
    # Or with custom API URL:
    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api

### Build for Production

    cd app
    flutter build web --dart-define=API_BASE_URL=https://your-backend-url.com/api

Output will be in `app/build/web/`, ready to deploy to Vercel / Netlify.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `sqlite:///./skyhorse.db` |
| `SECRET_KEY` | JWT signing key | `change-me-in-production` |
| `AI_PROVIDER` | AI engine: `deepseek`, `openai`, or `local` | `local` |
| `DEEPSEEK_API_KEY` | DeepSeek API key | *(empty)* |
| `OPENAI_API_KEY` | OpenAI API key (fallback) | *(empty)* |
| `ALLOWED_ORIGINS` | CORS allowed origins (comma-separated) | `*` |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Health check |
| `GET` | `/api/questions` | List questions (supports `?category=`, `?search=`) |
| `GET` | `/api/questions/{id}` | Get question detail |
| `GET` | `/api/questions/{id}/choice-stats` | Get vote distribution |
| `POST` | `/api/answers` | Submit an answer |
| `GET` | `/api/answers/{id}` | Get answer with AI score |
| `POST` | `/api/register` | Register a new user |
| `POST` | `/api/login` | Login and get JWT token |
| `GET` | `/api/me` | Get current user profile |
| `GET` | `/api/science/today` | Get today's science article |
| `GET` | `/api/forum/questions` | List forum discussions |

## Deployment

| Component | Platform | Plan |
|-----------|----------|------|
| **Database** | [Neon](https://neon.tech) | Free (permanent) |
| **Backend** | [Render](https://render.com) | Free |
| **Frontend** | [Vercel](https://vercel.com) | Free |

1. **Database**: Create a PostgreSQL project on Neon, copy the connection string
2. **Backend**: Create a Docker Web Service on Render — branch `v2.0`, root directory `backend`, add environment variables
3. **Frontend**: Run `flutter build web --dart-define=API_BASE_URL=https://your-api.onrender.com/api`, deploy `app/build/web/` to Vercel

## License

This project is for educational and personal use.