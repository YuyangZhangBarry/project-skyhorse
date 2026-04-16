#!/bin/bash
set -e

echo "==> Initializing database and seeding data..."
python seeds/load_seeds.py

echo "==> Starting Skyhorse API on port ${PORT:-8000}..."
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"
