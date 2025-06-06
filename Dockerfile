# ---- Build Stage ----
FROM ruby:3.4-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    npm \
    git \
    curl \
    vips-dev \
    yaml-dev \
    pkgconfig

WORKDIR /frens-app

# Install Yarn (via npm)
RUN npm install -g yarn

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle config set deployment 'true' && bundle install --without development test

# Copy the rest of the app
COPY . .

# Precompile assets (if using Rails assets)
RUN bundle exec rake assets:precompile

# ---- Production Stage ----
FROM ruby:3.4-alpine

# Install runtime dependencies only
RUN apk add --no-cache \
    postgresql-libs \
    nodejs \
    vips \
    yaml

WORKDIR /frens-app

# Copy only the necessary files from build stage
COPY --from=builder /frens-app ./
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["entrypoint.sh"]