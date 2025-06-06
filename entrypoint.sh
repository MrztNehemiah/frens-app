#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /frens-app/tmp/pids/server.pid

# Wait until Postgres is ready (with timeout)
echo "⏳ Waiting for Postgres to be ready..."
ATTEMPTS=0
MAX_ATTEMPTS=30

until pg_isready -h "${POSTGRES_HOST:-postgres-service}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-postgres}" -q; do
    ATTEMPTS=$((ATTEMPTS + 1))
    if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        echo "❌ Failed to connect to Postgres after $MAX_ATTEMPTS attempts"
        exit 1
    fi
    sleep 2
done

echo "✅ Postgres is ready. Running migrations..."
bundle exec rails db:migrate

echo "🚀 Starting Rails server..."
exec bundle exec rails server -b 0.0.0.0 -p 3000