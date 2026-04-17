<div align="center">

# Project Skyhorse - 天马行空问答

**一款支持中英双语的创意问答应用，搭载 AI 智能评分**

[English](README.md) / [简体中文](README_zh.md)

</div>

---

**在线访问：** [在浏览器中打开](https://web-nine-psi-56.vercel.app/)

## 简介

一款支持中英双语的创意问答应用，收录数十道富有想象力的问题。用户作答后，AI 从想象力、逻辑性、知识面、趣味性四个维度进行智能评分并给出个性化反馈。同时提供每日科普和社区讨论功能。

## 功能特色

- **创意问题** — 精选 5 大分类题目：科学、哲学、脑洞、生活、宇宙
- **双答题模式** — 选择题（投票统计）& 简答题（AI 评分）
- **AI 智能评分** — DeepSeek / OpenAI 驱动，四维度评分 + 个性化反馈
- **每日科普** — 每天推送一条科学概念/理论，支持社区讨论
- **社区论坛** — 分享和讨论其他用户的回答
- **中英双语** — UI、题目、AI 反馈等所有内容均可一键切换中英文
- **个人主页** — 查看答题记录和平均分数

## 技术栈

| 层级 | 技术 |
|------|------|
| **前端** | Flutter 3（Web / Android / iOS） |
| **后端** | Python 3.12 + FastAPI |
| **数据库** | PostgreSQL（Neon） |
| **AI 评分** | DeepSeek API（主）/ OpenAI（备）/ 本地评分器（离线） |
| **状态管理** | Riverpod |
| **路由** | GoRouter |
| **部署** | Render（后端）+ Vercel（前端） |

## 项目结构

    project-skyhorse/
    ├── app/                          # Flutter 前端
    │   ├── lib/
    │   │   ├── config/               # 主题、路由配置
    │   │   ├── l10n/                 # 国际化文件
    │   │   ├── models/               # 数据模型
    │   │   ├── providers/            # Riverpod 状态管理
    │   │   ├── screens/              # 页面
    │   │   │   ├── auth/             # 登录 & 注册
    │   │   │   ├── home/             # 题目列表 & 搜索
    │   │   │   ├── question/         # 答题页
    │   │   │   ├── result/           # AI 评分结果
    │   │   │   ├── choice_result/    # 选择题投票统计
    │   │   │   ├── forum/            # 社区论坛
    │   │   │   ├── main_shell/       # 底部导航 & 科普页
    │   │   │   ├── profile/          # 个人主页
    │   │   │   └── submit/           # 提交自定义问题
    │   │   ├── services/             # API 请求层
    │   │   ├── utils/                # 共享工具函数
    │   │   └── widgets/              # 可复用 UI 组件
    │   └── pubspec.yaml
    ├── backend/                      # FastAPI 后端
    │   ├── app/
    │   │   ├── api/                  # 路由（题目、回答、论坛、科普、用户）
    │   │   ├── core/                 # 配置、数据库、鉴权、国际化
    │   │   ├── models/               # SQLAlchemy ORM 模型
    │   │   ├── services/             # AI 评分引擎
    │   │   └── tasks/                # 评分任务
    │   ├── seeds/                    # 种子数据（60 道双语题目 + 科普文章）
    │   ├── migrations/               # Alembic 数据库迁移
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── start.sh                  # 入口：初始化数据库 + 启动服务
    └── README.md

## 快速开始

### 环境要求

- **Flutter** >= 3.11
- **Python** >= 3.12
- **PostgreSQL**（本地开发可用 SQLite）

### 后端启动

    cd backend
    python -m venv venv
    source venv/bin/activate          # Windows: venv\Scripts\activate
    pip install -r requirements.txt
    cp .env.example .env              # 然后编辑 .env 配置环境变量
    python seeds/load_seeds.py        # 初始化数据库并导入种子数据
    uvicorn app.main:app --reload --port 8000

API 地址：http://localhost:8000，健康检查：`GET /api/health`。

### 前端启动

    cd app
    flutter pub get
    flutter run -d chrome
    # 或指定后端地址运行：
    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api

### 生产构建

    cd app
    flutter build web --dart-define=API_BASE_URL=https://你的后端地址.com/api

产物在 `app/build/web/`，可直接部署到 Vercel / Netlify。

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DATABASE_URL` | PostgreSQL 连接字符串 | `sqlite:///./skyhorse.db` |
| `SECRET_KEY` | JWT 签名密钥 | `change-me-in-production` |
| `AI_PROVIDER` | AI 引擎：`deepseek`、`openai` 或 `local` | `local` |
| `DEEPSEEK_API_KEY` | DeepSeek API 密钥 | *(空)* |
| `OPENAI_API_KEY` | OpenAI API 密钥（备选） | *(空)* |
| `ALLOWED_ORIGINS` | CORS 允许的域名（逗号分隔） | `*` |

## API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/health` | 健康检查 |
| `GET` | `/api/questions` | 题目列表（支持 `?category=`、`?search=`） |
| `GET` | `/api/questions/{id}` | 题目详情 |
| `GET` | `/api/questions/{id}/choice-stats` | 选择题投票分布 |
| `POST` | `/api/answers` | 提交回答 |
| `GET` | `/api/answers/{id}` | 获取回答及 AI 评分 |
| `POST` | `/api/register` | 注册 |
| `POST` | `/api/login` | 登录，获取 JWT Token |
| `GET` | `/api/me` | 获取当前用户信息 |
| `GET` | `/api/science/today` | 获取今日科普 |
| `GET` | `/api/forum/questions` | 论坛讨论列表 |

## 部署方案

| 组件 | 平台 | 方案 |
|------|------|------|
| **数据库** | [Neon](https://neon.tech) | 免费（永久） |
| **后端** | [Render](https://render.com) | 免费 |
| **前端** | [Vercel](https://vercel.com) | 免费 |

1. **数据库**：在 Neon 创建 PostgreSQL 项目，复制连接字符串
2. **后端**：在 Render 创建 Docker Web Service，分支 `v2.0`，根目录 `backend`，配置环境变量
3. **前端**：执行 `flutter build web --dart-define=API_BASE_URL=https://你的后端.onrender.com/api`，将 `app/build/web/` 部署到 Vercel

## 许可

本项目仅供学习和个人使用。