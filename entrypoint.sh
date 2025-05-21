#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /frens-app/tmp/pids/server.pid

# Wait until Postgres is ready
echo "⏳ Waiting for Postgres to be ready..."
until pg_isready -h postgres-service -p 5432 -U postgres; do
  sleep 1
done

echo "✅ Postgres is ready. Running migrations..."
bundle exec rails db:migrate

echo "🚀 Starting Rails server..."
exec bundle exec rails server -b 0.0.0.0 -p 3000