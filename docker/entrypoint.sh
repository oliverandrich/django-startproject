#!/usr/bin/env bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euxo pipefail

echo "Migrate database..."
python manage.py migrate

echo "Start granian..."
granian {{ project_name }}.wsgi:application \
    --host 0.0.0.0 \
    --port 8000 \
    --interface wsgi \
    --no-ws \
    --loop uvloop \
    --process-name \
    "granian [{{ project_name }}]"
