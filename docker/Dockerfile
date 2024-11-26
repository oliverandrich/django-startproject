# syntax=docker.io/docker/dockerfile:1.7-labs

# Stage 1: General debian environment
FROM python:3.13-slim-bookworm AS linux-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    TAILWIND_CLI_PATH="/opt/tailwind"

# Tweaking the PATH variable for easier use
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Update debian
RUN apt-get update
RUN apt-get upgrade -y

# Install general required dependencies
RUN apt-get install --no-install-recommends -y tzdata

# Stage 2: Python environment
FROM linux-base AS builder-base

# Install debian dependencies
RUN apt-get install --no-install-recommends -y build-essential gettext curl

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Create virtual environment and install dependencies
WORKDIR $PYSETUP_PATH
COPY pyproject.toml ./
COPY poetry.lock ./
RUN poetry install --only main --all-extras

# Copy the webapp files
COPY . /app
WORKDIR /app

# Byte compile the source files
RUN SECRET_KEY="dockerbuild" python -m compileall webapp

# Build static files
RUN SECRET_KEY="dockerbuild" python manage.py tailwind build
RUN SECRET_KEY="dockerbuild" python manage.py collectstatic --no-input

# Compile translation files
RUN SECRET_KEY="dockerbuild" python manage.py compilemessages

# Stage 3: Webapp environment
FROM linux-base AS webapp

# Create a non-root user
RUN useradd -m appuser

# Copy python, virtual env and static assets
COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY --from=builder-base --exclude=poetry.lock --exclude=pyproject.toml /app /app

# Change ownership of the application files to the non-root user
RUN chown -R appuser:appuser /app $VENV_PATH

# Switch to the non-root user
USER appuser

# Start the application server
WORKDIR /app
EXPOSE 8000
CMD ["docker/entrypoint.sh"]
