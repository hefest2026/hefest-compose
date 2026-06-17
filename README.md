# hefest-compose

Docker Compose setup for local development of the Hefest platform.

## Prerequisites

- Docker with the Compose plugin (`docker compose version`)
- Git (to clone missing repos)

No other tools needed — Python, uv, and all dependencies run inside containers.

## First-time setup

```bash
./setup.sh
```

The script:
1. Clones `hefest2026/hefest-api` into `../hefest-api` if not already present
2. Creates `.env` from `.env.example` if not already present
3. Builds the API image and starts all services
4. Waits for the API to be healthy, then runs database migrations

## Day-to-day

```bash
# Start services
docker compose up -d

# Tail API logs
docker compose logs -f api

# Run a migration
docker compose exec api uv run tortoise -c hefest.config.TORTOISE_ORM migrate

# Generate a new migration after model changes
docker compose exec api uv run tortoise -c hefest.config.TORTOISE_ORM makemigrations

# Roll back last migration
docker compose exec api uv run tortoise -c hefest.config.TORTOISE_ORM downgrade -v -1

# Open a shell in the API container
docker compose exec api bash

# Stop services
docker compose down

# Wipe all volumes and start fresh
docker compose down -v && docker compose up -d
```

## Services

| Service | Image | Local port |
|---------|-------|------------|
| postgres | postgres:16-alpine | 5432 |
| api | built from `../hefest-api` | 8000 |

## Environment variables

Copy `.env.example` to `.env` (done automatically by `setup.sh`):

| Variable | Default | Description |
|----------|---------|-------------|
| `HEFEST_JWT_SECRET` | `change-me-for-local-dev` | JWT signing key — change before any shared env |

Database and Redis URLs are set directly in `compose.yml` using the service hostnames; they do not need to be in `.env`.

## Endpoints

| URL | Purpose |
|-----|---------|
| `http://localhost:8000/health` | Liveness probe |
| `http://localhost:8000/ready` | Readiness probe (checks Postgres + Redis) |
| `http://localhost:8000/docs` | Swagger UI |
