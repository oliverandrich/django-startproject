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

    echo "Installing dependencies"
    uv sync --all-extras

    echo "Creating default tailwind.config.js"
    uv run python manage.py tailwind build

# upgrade/install all dependencies defined in pyproject.toml
@upgrade: check_uv
    uv sync --upgrade --all-extras

# run database migrations
@migrate *ARGS: check_uv
    uv run manage.py migrate {{ ARGS }}

# create database migrations
@makemigrations *ARGS: check_uv
    uv run manage.py makemigrations {{ ARGS }}

# start debugserver
@debugserver *ARGS: check_uv
    uv run manage.py tailwind runserver_plus {{ ARGS }}

alias runserver := debugserver

# start interactive shell
@shell *ARGS: check_uv
    uv run manage.py shell_plus {{ ARGS }}

# start manage.py for all cases not covered by other commands
@manage *ARGS: check_uv
    uv run manage.py {{ ARGS }}

# run pre-commit rules on all files
@lint: check_uv
    uv run -m pre_commit run --all-files

# run test suite
@test *ARGS: check_uv
    uv run -m pytest {{ ARGS }}

# run test suite with coverage
@coverage *ARGS: check_uv
    uv run -m pytest --cov --cov-report term-missing
