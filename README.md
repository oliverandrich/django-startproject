# django-startproject

![Screenshot of the landing page](docs/landingpage.png)

> Django startproject template with batteries and nice tooling.

I took the inspiration from Jeff Triplett's [django-startproject](https://github.com/jefftriplett/django-startproject) and created my own starter for a fresh django project. It includes the batteries I use regularly. 🤷‍♂️

The template is also inspired by Carlton Gibson's Post [The Single Folder Django Project Layout](https://noumenal.es/notes/django/single-folder-layout/). It uses the single folder layout as a start as I always run in the same situation Carlton describes in his post. If you have to split the project into several apps, you can always call `python manage.py startapp` later on.

Out of the box SQLite is configured, but you can easily activate MySQL or Postgres support.

## Features

- Python 3.12
- Django 5.0.x
- django-browser-reload
- django-htmx
- django-tailwind-cli
- django-typer
- django-allauth
- environs\[django\]
- heroicons
- whitenoise
- SQLite setup with WAL mode enabled (See `<project_name>/__init__.py`.)
- [Argon2 password hashing is activated](https://docs.djangoproject.com/en/4.1/topics/auth/passwords/)
- Local install of htmx.
- uses the [single folder Django project layout](https://noumenal.es/notes/django/single-folder-layout/)
- [adds some standard templatetags to the builtins](https://adamj.eu/tech/2023/09/15/django-move-template-tag-library-builtins/)

### Development tools

- django-types
- django-test-plus
- model-bakery
- pytest
- pytest-cov
- pytest-django
- pytest-mock
- pre-commit setup inspired by [Boost your Django DX](https://adamchainz.gumroad.com/l/byddx)
- sane ruff configuration
- [just](https://github.com/casey/just) for project management and maintenance

## Install

```shell
$ django-admin startproject \
      --extension=py,toml \
      --template=https://github.com/oliverandrich/django-startproject/archive/main.zip \
      example_project

# Setup environment and install dependencies
$ just bootstrap

# Migrate database
$ just migrate

# Start dev server
$ just runserver
```

## Usage

```shell
# Bootstrap the project and install dependencies
just boostrap

# Upgrade/install all dependencies defined in pyproject.toml
just upgrade

# Run database migrations
just migrate

# Create database migrations
just makemigrations

# Start debugserver
just runserver
# or
just debugserver

# Start the interactive django shell
just shell

# Start manage.py for all cases not covered by other commands
just manage ...

# Run pre-commit rules on all files
just lint

# Run test suite
just test

# Lock dependencies for the Dockerfile
just lock

# Update htmx to the latest stable version
just update_htmx
```

## Environemt Variables for Docker and your .env file

Or when run as a [12-Factor application](https://12factor.net).

| Environment Variable         | Default                               | Location         |
| ---------------------------- | ------------------------------------- | ---------------- |
| ALLOWED_HOSTS                | []                                    | settings.py      |
| CACHE_URL                    | "locmem://"                           | settings.py      |
| CSRF_TRUSTED_ORIGINS         | []                                    | settings.py      |
| DATABASE_URL                 | "sqlite:///db/db.sqlite3?timeout=20"  | settings.py      |
| DEBUG                        | False                                 | settings.py      |
| EMAIL_URL                    | "console:"                            | settings.py      |
| GUNICORN_BIND                | "0.0.0.0:8000"                        | gunicorn.conf.py |
| GUNICORN_MAX_REQUESTS        | 1000                                  | gunicorn.conf.py |
| GUNICORN_MAX_REQUESTS_JITTER | 50                                    | gunicorn.conf.py |
| GUNICORN_WORKERS             | `multiprocessing.cpu_count() * 2 + 1` | gunicorn.conf.py |
| INTERNAL_IPS                 | []                                    | settings.py      |
| LANGUAGE_CODE                | "EN"                                  | settings.py      |
| SECRET_KEY                   | `get_random_secret_key()`             | settings.py      |
| TAILWIND_CLI_PATH            | "~/.local/bin"                        | settings.py      |
| TIME_ZONE                    | "UTC"                                 | settings.py      |

## Docker and docker-compose

The `Dockerfile` uses a multi stage process to embracing caching for building the container images.

## Contributing

Contributions, issues and feature requests are welcome!
Feel free to check [issues page](https://github.com/oliverandrich/django-startproject/issues).
