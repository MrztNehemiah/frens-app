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

# Install specific bundler version and yarn
RUN gem install bundler:2.6.8 && npm install -g yarn

# Copy dependency files first (better caching)
COPY Gemfile Gemfile.lock package.json yarn.lock* ./

# Install gems and JS dependencies
RUN bundle config set --local without 'development test' && \
    bundle install && \
    yarn install --frozen-lockfile

# Copy source code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# ---- Production Stage ----
FROM ruby:3.4-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-libs \
    nodejs \
    vips \
    yaml \
    tzdata

WORKDIR /frens-app

# Create non-root user
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Copy application and bundler gems
COPY --from=builder --chown=appuser:appgroup /frens-app ./
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy and setup entrypoint
COPY --chown=appuser:appgroup entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

USER appuser
EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]