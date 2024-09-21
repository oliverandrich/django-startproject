set export
set dotenv-load

@_default:
    just --list

[private]
@check_uv:
    if ! command -v uv &> /dev/null; then \
        echo "uv could not be found. Exiting."; \
        exit; \
    fi

# bootstrap the project and install dependencies
@bootstrap: check_uv
    if [ -x .env ]; then \
        echo "Already bootstraped. Exiting."; \
        exit; \
    fi

    echo "Creating .env file"
    echo "# Activate debug mode for Django framework." >> .env
    echo "DEBUG=true" >> .env
    echo "# Required for unittest discovery in VSCode." >> .env
    echo "MANAGE_PY_PATH='manage.py'" >> .env

    echo "Creating .envrc file for direnv"
    echo "test -d .venv || uv sync --frozen" >> .envrc
    echo "source .venv/bin/activate" >> .envrc
    test -x "$(command -v direnv)" && direnv allow

    echo "Installing dependencies"
    uv sync --all-extras

    echo "Creating default tailwind.config.js"
    uv run python manage.py tailwind build

# upgrade/install all dependencies defined in pyproject.toml
@upgrade: check_uv
    uv sync --all-extras

# run database migrations
@migrate *ARGS: check_uv
    uv run python3 manage.py migrate {{ ARGS }}

# create database migrations
@makemigrations *ARGS: check_uv
    uv run python3 manage.py makemigrations {{ ARGS }}

# start debugserver
@debugserver *ARGS: check_uv
    uv run python3 manage.py tailwind runserver_plus {{ ARGS }}

alias runserver := debugserver

# start interactive shell
@shell *ARGS: check_uv
    uv run python3 manage.py shell_plus {{ ARGS }}

# start manage.py for all cases not covered by other commands
@manage *ARGS: check_uv
    uv run python3 manage.py {{ ARGS }}

# run pre-commit rules on all files
@lint: check_uv
    uvx --with pre-commit-uv pre-commit run --all-files

# run test suite
@test *ARGS: check_uv
    uv run python3 -W ignore::UserWarning manage.py test {{ ARGS }}

# run test suite with coverage
@coverage *ARGS: check_uv
    uv run python3 -W ignore::UserWarning -m coverage run manage.py test {{ ARGS }}
    uv run python3 -W ignore::UserWarning -m coverage report -m
    uv run python3 -W ignore::UserWarning -m coverage html
