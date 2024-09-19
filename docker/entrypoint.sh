#!/bin/sh

set -eu

echo "Migrating database..."
python manage.py migrate

echo "Starting granian..."
exec granian "{{ project_name }}.wsgi:application" \
    --host 0.0.0.0 \
    --port 8000 \
    --interface wsgi \
    --no-ws \
    --loop uvloop \
    --process-name "granian [{{ project_name }}]"
