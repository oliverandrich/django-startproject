# Stage 1: General enviroment
FROM python:3.12-slim-bookworm AS python-base
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
  UV_COMPILE_BYTECODE=1 \
  UV_PYTHON_DOWNLOADS=never \
  UV_PYTHON=python3.12 \
  UV_PROJECT_ENVIRONMENT=/venv

ENV PATH="$UV_PROJECT_ENVIRONMENT/bin:$PATH"

# Stage 2: Install dependencies & build static files
FROM python-base AS builder-base

# Install debian dependencies
RUN apt-get update && apt-get install --no-install-recommends -y build-essential tzdata gettext

# Install dependencies
COPY pyproject.toml ./
COPY uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

# Build static files
COPY . /app
WORKDIR /app
RUN python manage.py tailwind build
RUN python manage.py collectstatic --no-input

# Stage 3: Run service
FROM python-base AS production

# Assure UTF-8 encoding is used.
ENV LC_CTYPE=C.utf8

# Copy application code from builder-base
COPY --from=builder-base $UV_PROJECT_ENVIRONMENT $UV_PROJECT_ENVIRONMENT
COPY --from=builder-base /app/static /app/static
COPY . /app

WORKDIR /app
EXPOSE 8000
CMD ["./docker-entrypoint.sh"]
