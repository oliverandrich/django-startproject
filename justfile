set export
set dotenv-load

@_default:
    just --list

[private]
@check_poetry:
    if ! command -v poetry &> /dev/null; then \
        echo "poetry could not be found. Exiting."; \
        exit; \
    fi

# bootstrap the project and install dependencies
@bootstrap: check_poetry
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
    poetry install

    echo "Creating default tailwind.config.js"
    poetry run python manage.py tailwind build

# upgrade/install all dependencies defined in pyproject.toml
@upgrade: check_poetry
    poetry update

# run database migrations
@migrate *ARGS: check_poetry
    poetry run python manage.py migrate {{ ARGS }}

# create database migrations
@makemigrations *ARGS: check_poetry
    poetry run python manage.py makemigrations {{ ARGS }}

# start debugserver
@debugserver *ARGS: check_poetry
    poetry run python manage.py tailwind runserver_plus {{ ARGS }}

alias runserver := debugserver

# start interactive shell
@shell *ARGS: check_poetry
    poetry run python manage.py shell_plus {{ ARGS }}

# start manage.py for all cases not covered by other commands
@manage *ARGS: check_poetry
    poetry run python manage.py {{ ARGS }}

# run pre-commit rules on all files
@lint: check_poetry
    poetry run python -m pre_commit run --all-files

# run test suite
@test *ARGS: check_poetry
    poetry run python -W ignore::UserWarning manage.py test {{ ARGS }}

# run test suite with coverage
@coverage *ARGS: check_poetry
    poetry run python -W ignore::UserWarning -m coverage run manage.py test {{ ARGS }}
    poetry run python -W ignore::UserWarning -m coverage report -m
    poetry run python -W ignore::UserWarning -m coverage html
