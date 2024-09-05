set export
set dotenv-load

VENV_DIRNAME := ".venv"

@_default:
    just --list

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
    echo "DEBUG=true" >> .env

    echo "Installing dependencies"
    poetry install

    echo "Creating default tailwind.config.js"
    poetry run python3 manage.py tailwind build

# upgrade/install all dependencies defined in pyproject.toml
@upgrade: check_poetry
    $VENV_DIRNAME/bin/python3 -m pip install --upgrade pip uv; \
    $VENV_DIRNAME/bin/python3 -m uv pip install --upgrade \
        --requirement pyproject.toml --all-extras;

# run database migrations
@migrate *ARGS: check_poetry
    poetry run python3 manage.py migrate {{ ARGS }}

# create database migrations
@makemigrations *ARGS: check_poetry
    poetry run python3 manage.py makemigrations {{ ARGS }}

# start debugserver
@debugserver *ARGS: check_poetry
    poetry run python3 manage.py tailwind runserver_plus {{ ARGS }}

alias runserver := debugserver

# start interactive shell
@shell *ARGS: check_poetry
    poetry run python3 manage.py shell_plus {{ ARGS }}

# start manage.py for all cases not covered by other commands
@manage *ARGS: check_poetry
    poetry run python3 manage.py {{ ARGS }}

# run pre-commit rules on all files
@lint *ARGS: check_poetry
    poetry run pre-commit run {{ ARGS }} --all-files

# run test suite
@test *ARGS: check_poetry
    poetry run python3 -W ignore::UserWarning manage.py test {{ ARGS }}

@coverage *ARGS: check_poetry
    poetry run python3 -W ignore::UserWarning -m coverage run manage.py test {{ ARGS }}
    poetry run python3 -W ignore::UserWarning -m coverage report -m
    poetry run python3 -W ignore::UserWarning -m coverage html
