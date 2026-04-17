# Agent 维护文档（随仓库同步）

| 文件 | 用途 |
|------|------|
| `AGENT_ONBOARDING.md` | 项目结构、约定、部署、约束 — **给新 Agent 的主上下文** |
| `MAINTENANCE_LOG.md` | 按日维护日志模板 |
| `PROMPT_SNIPPET.txt` | 可粘贴到对话开头的短提示词骨架 |

## 本地私有副本（可选）

项目根目录的 `maintenance/` 已写入 `.gitignore`，可存放你从本目录复制的文件及个人私密日志，**不会进入 Git**。

```bash
mkdir -p maintenance
cp docs/agent/AGENT_ONBOARDING.md docs/agent/MAINTENANCE_LOG.md docs/agent/PROMPT_SNIPPET.txt maintenance/
```

之后只在 `maintenance/` 里追加敏感记录即可；与远程同步时以 `docs/agent/` 为模板更新。
