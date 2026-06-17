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

echo "Done. API: http://localhost:8000  Docs: http://localhost:8000/docs"
