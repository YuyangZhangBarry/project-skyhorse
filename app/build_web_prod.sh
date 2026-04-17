#!/usr/bin/env bash
# Usage: ./build_web_prod.sh https://your-service.onrender.com/api
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
URL="${1:-}"
if [[ -z "$URL" ]]; then
  echo "用法: ./build_web_prod.sh <生产环境 API 基址>"
  echo "示例: ./build_web_prod.sh https://skyhorse-api.onrender.com/api"
  exit 1
fi
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="$URL"
echo ""
echo "构建完成，产物目录: $ROOT/build/web"
echo "下一步: 将 build/web 部署到 Vercel（或 vercel --prod）"
