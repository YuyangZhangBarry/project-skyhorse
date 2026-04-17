#!/usr/bin/env bash
# 在已登录 Vercel CLI 的前提下，将 build/web 部署到生产环境。
# 首次使用请先执行: npx vercel login
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
if [[ ! -f "$ROOT/build/web/index.html" ]]; then
  echo "未找到 build/web，请先执行: ./build_web_prod.sh https://skyhorse-api.onrender.com/api"
  exit 1
fi
cd "$ROOT/build/web"
exec npx --yes vercel@latest deploy . --prod
