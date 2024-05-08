# Stage 1: General enviroment
FROM python:3.12-slim-bookworm AS python-base
ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  TAILWIND_CLI_PATH="/opt/tailwind"

ENV PATH="$VENV_PATH/bin:$PATH"

# Stage 2: Install dependencies & build static files
FROM python-base as builder-base

# Install dependencies
WORKDIR $PYSETUP_PATH
COPY ./requirements.txt ./
RUN python -m pip install --upgrade pip uv
RUN python -m uv pip install --system --requirement ./requirements.txt

# Build static files
COPY . /app
WORKDIR /app
RUN python manage.py tailwind build
RUN python manage.py collectstatic --no-input

# Stage 3: Run service
FROM python-base as production

COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY --from=builder-base /app/static /app/static
COPY . /app

WORKDIR /app
EXPOSE 8000
CMD ["./docker-entrypoint.sh"]
