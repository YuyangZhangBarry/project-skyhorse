# Skyhorse / 天马行空 — Agent 维护上下文

> **仓库模板**：可整份复制到项目根目录 `maintenance/`（已 gitignore）作个人修改；远程克隆若无 `maintenance/`，请读本文件与 `MAINTENANCE_LOG.md`。
>
> 把本文件与 `MAINTENANCE_LOG.md` 一并作为对话首条消息或 @ 引用，便于新会话快速对齐。

## 项目一句话

双语（中/英）创意问答 Web/App：题目来自后端种子数据，简答题由 DeepSeek/OpenAI/本地评分器打分；含论坛、每日科普、个人主页。**必须登录**后使用全部功能（无付费墙）。

---

## 仓库结构（根目录）

| 路径 | 说明 |
|------|------|
| `app/` | Flutter 前端（Web/Android/iOS） |
| `app/lib/` | 源码：`config/` 路由与主题，`l10n/` ARB 生成文案，`providers/` Riverpod，`screens/`，`services/api_service.dart`，`models/` |
| `app/web/` | Flutter Web 静态资源 + `vercel.json`（SPA 重写） |
| `app/build_web_prod.sh` | 生产构建：`./build_web_prod.sh https://<API>/api` |
| `app/deploy_vercel.sh` | 部署 `build/web` 到 Vercel（需先 `vercel login`） |
| `backend/` | FastAPI + SQLAlchemy |
| `backend/app/api/` | 路由：`users.py` 注册登录，`questions.py`，`answers.py`，`forum.py`，`science.py`，`user_questions.py` |
| `backend/app/core/` | `config.py` 环境变量，`database.py`，`security.py` JWT，`i18n.py` `get_lang` / `pick` |
| `backend/app/services/ai_scorer.py` | AI 与本地评分，`lang` 参数 |
| `backend/seeds/questions.json` | 60 道题双语种子 |
| `backend/seeds/sciences.json` | 科普文章池（轮换） |
| `backend/seeds/load_seeds.py` | 建表、导题、**仅补当天** `daily_science` |
| `backend/seeds/reset_daily_science.py` | 清空科普表+评论后只插今天（需 ORM 依赖齐全） |
| `backend/start.sh` | Docker 入口：`load_seeds` + `uvicorn` |
| `README.md` / `README_zh.md` | 双语说明（仓库内**可提交**的正式文档） |

---

## 环境与密钥（勿提交）

- 后端：`backend/.env`（gitignore），参考 `backend/.env.example`
- 关键变量：`DATABASE_URL`，`SECRET_KEY`，`AI_PROVIDER`，`DEEPSEEK_API_KEY`，`ALLOWED_ORIGINS`（生产填前端域名）
- Flutter 生产 API：`--dart-define=API_BASE_URL=https://.../api`

---

## 双语约定

- 前端：`localeProvider`，`ApiService.setLanguage` 与 `main` 里 locale 同步；请求头 **`X-App-Language`: `zh` | `en`**（勿依赖浏览器 `Accept-Language` 单独决定业务语言）。
- 后端：`app/core/i18n.py` 的 `get_lang(request)` 优先读 `x-app-language`；`pick(zh, en, lang)` 选文案。
- 题目/选项/科普：库里有 `title` / `title_en`、`content` / `content_en` 等字段；论坛 `selected_option` 对选择题用 `ChoiceOption` 做中英文匹配后 `pick`。

---

## 部署（当前常见方案）

| 组件 | 平台 | 备注 |
|------|------|------|
| DB | Neon（PostgreSQL） | 连接串含 `sslmode=require` |
| API | Render，Docker，`backend/` 根目录，分支常用 `main` | `PORT` 由平台注入 |
| 前端 | Vercel，静态目录 `app/build/web` | 部署后把 `ALLOWED_ORIGINS` 指向前端域名 |

免费 Render **无 Shell**：清库用 **Neon SQL Editor** 执行 `DELETE`，或本地设 `DATABASE_URL` 跑 `python seeds/reset_daily_science.py`。

---

## 常见操作

- **本地后端**：`cd backend && uvicorn app.main:app --reload --port 8000`（先 `load_seeds` 或已有 DB）
- **本地前端**：`cd app && flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api`
- **改文案**：编辑 `app/lib/l10n/app_zh.arb` / `app_en.arb` 后 `flutter gen-l10n`（若未自动化）
- **依赖**：`passlib` 需 **`bcrypt>=4.0.1,<4.1`**（见 `requirements.txt`），避免注册 72-byte 报错
- **科普重复标题历史原因**：曾按「当天」反复插同一篇；现改为只插当天 + `sciences.json` 按日期轮换；旧数据需 SQL 或 reset 脚本清理

---

## 产品约束（维护时请勿擅自恢复）

- 无游客模式：**未登录**应被路由/接口挡在需登录页（以当前 `router` 与 `get_current_user` 为准）。
- 无付费墙：不要恢复 `UserTier` / `isFree` 等限制逻辑。
- 数据库：生产用 PostgreSQL；本地常用 SQLite `skyhorse.db`。

---

## 给新 Agent 的推荐首条提示词（可粘贴）

```
你是接手 Skyhorse（天马行空）项目的开发助手。请先阅读 docs/agent/AGENT_ONBOARDING.md（或 maintenance/ 下副本）与 MAINTENANCE_LOG.md 最近条目，遵守双语与部署约定；改代码时尽量小范围 diff，不要恢复付费/游客逻辑。当前分支与部署目标以用户说明为准。
```

---

## 文档更新说明

对外正式说明以仓库根目录 `README.md` / `README_zh.md` 为准；本文件为 Agent 维护上下文。
