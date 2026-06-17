#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$SCRIPT_DIR/../hefest-api"

# ── repos ────────────────────────────────────────────────────────────────────

clone_if_missing() {
    local dir="$1" repo="$2"
    if [[ ! -d "$dir" ]]; then
        echo "Cloning $repo..."
        git clone "https://github.com/hefest2026/$repo" "$dir"
    else
        echo "$repo already present, skipping clone."
    fi
}

clone_if_missing "$API_DIR" "hefest-api"

# ── .env ─────────────────────────────────────────────────────────────────────

ENV_FILE="$SCRIPT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    cp "$SCRIPT_DIR/.env.example" "$ENV_FILE"
    echo "Created .env from .env.example — set HEFEST_JWT_SECRET before going to production."
fi

# ── compose ───────────────────────────────────────────────────────────────────

cd "$SCRIPT_DIR"
docker compose up -d --build

# ── migrations ────────────────────────────────────────────────────────────────

echo "Waiting for api to become healthy..."
for i in $(seq 1 30); do
    if docker compose exec api python -c \
        "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" \
        2>/dev/null; then
        break
    fi
    [[ $i -eq 30 ]] && { echo "API did not become healthy in time."; exit 1; }
    sleep 2
done

echo "Running migrations..."
docker compose exec api uv run tortoise -c hefest.config.TORTOISE_ORM migrate

echo "Done. API: http://localhost:8000  Docs: http://localhost:8000/docs"
