set export
set dotenv-load

VENV_DIRNAME := ".venv"

@_default:
    just --list

# bootstrap the project and install dependencies
@bootstrap:
    if [ -x .env ]; then \
        echo "Already bootstraped. Exiting."; \
        exit; \
    fi

    echo "Creating .env file"
    echo "DEBUG=true" >> .env

    if `which -s direnv2`; then \
        echo "Creating .envrc and activating direnv"; \
        echo "export VIRTUAL_ENV=.venv" > .envrc; \
        echo "layout python3" > .envrc; \
        direnv allow; \
    else \
        echo "Creating virtual env in .venv"; \
        just create_venv; \
    fi

    echo "Installing dependencies"
    just upgrade

# create a virtual environment
@create_venv:
    [ -d .venv ] || python3 -m venv $VENV_DIRNAME; \

# upgrade/install all dependencies defined in pyproject.toml
@upgrade: create_venv
    $VENV_DIRNAME/bin/python3 -m pip install --upgrade pip uv; \
    $VENV_DIRNAME/bin/python3 -m uv pip install --upgrade \
        --requirement pyproject.toml --all-extras;

# run database migrations
@migrate *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 manage.py migrate {{ ARGS }}

# create database migrations
@makemigrations *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 manage.py makemigrations {{ ARGS }}

# start debugserver
@debugserver *ARGS: create_venv
    echo $DEBUG
    $VENV_DIRNAME/bin/python3 manage.py tailwind runserver_plus {{ ARGS }}

alias runserver := debugserver

# start interactive shell
@shell *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 manage.py shell_plus {{ ARGS }}

# start manage.py for all cases not covered by other commands
@manage *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 manage.py {{ ARGS }}

# run pre-commit rules on all files
@lint *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 -m pre_commit run {{ ARGS }} --all-files

# run test suite
@test *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 -m pytest {{ ARGS }}

# lock dependencies
@lock *ARGS: create_venv
    $VENV_DIRNAME/bin/python3 -m uv pip compile {{ ARGS }} ./pyproject.toml \
        --quiet \
        --resolver=backtracking \
        --output-file ./requirements.txt
    echo "Created requirements.txt"

# update htmx to the latest stable version
update_htmx:
    curl -L https://unpkg.com/htmx.org@latest/dist/htmx.min.js > assets/js/htmx.min.js
