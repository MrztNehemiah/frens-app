#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /frens-app/tmp/pids/server.pid

# Wait until Postgres is ready
echo "⏳ Waiting for Postgres to be ready..."
until pg_isready -h "${POSTGRES_HOST:-postgres-service}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-postgres}"; do
  sleep 1
done

echo "✅ Postgres is ready. Running migrations..."
bundle exec rails db:migrate

echo "🚀 Starting Rails server..."
exec bundle exec rails server -b 0.0.0.0 -p 3000