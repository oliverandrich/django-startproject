# syntax=docker.io/docker/dockerfile:1.7-labs

# Stage 1: General debian environment
FROM debian:stable-slim AS linux-base

# Assure UTF-8 encoding is used.
ENV LC_CTYPE=C.utf8
# Location of the virtual environment
ENV UV_PROJECT_ENVIRONMENT="/venv"
# Location of the python installation via uv
ENV UV_PYTHON_INSTALL_DIR="/python"
# Byte compile the python files on installation
ENV UV_COMPILE_BYTECODE=1
# Python verision to use
ENV UV_PYTHON=python3.13
# Tweaking the PATH variable for easier use
ENV PATH="$UV_PROJECT_ENVIRONMENT/bin:$PATH"

# Update debian
RUN apt-get update
RUN apt-get upgrade -y

# Install general required dependencies
RUN apt-get install --no-install-recommends -y tzdata

# Stage 2: Python environment
FROM linux-base AS python-base

# Install debian dependencies
RUN apt-get install --no-install-recommends -y build-essential gettext

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Create virtual environment and install dependencies
COPY pyproject.toml ./
COPY uv.lock ./
RUN uv sync --all-extras --frozen --no-dev --no-install-project

# Stage 3: Building environment
FROM python-base AS builder-base

WORKDIR /app
COPY . /app

# Build static files
RUN python manage.py tailwind build
RUN python manage.py collectstatic --no-input

# Compile translation files
RUN python manage.py compilemessages

# Stage 4: Webapp environment
FROM linux-base AS webapp

# Create a non-root user
RUN useradd -m appuser

# Copy python, virtual env and static assets
COPY --from=builder-base $UV_PYTHON_INSTALL_DIR $UV_PYTHON_INSTALL_DIR
COPY --from=builder-base $UV_PROJECT_ENVIRONMENT $UV_PROJECT_ENVIRONMENT
COPY --from=builder-base --exclude=uv.lock --exclude=pyproject.toml /app /app

# Change ownership of the application files to the non-root user
RUN chown -R appuser:appuser /app $UV_PROJECT_ENVIRONMENT $UV_PYTHON_INSTALL_DIR

# Switch to the non-root user
USER appuser

# Start the application server
WORKDIR /app
EXPOSE 8000
CMD ["docker/entrypoint.sh"]
