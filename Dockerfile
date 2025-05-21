FROM ruby:3.4-slim

# Create the working directory
RUN mkdir frens-app

# Set the working directory 
WORKDIR /frens-app

# Install system dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    git \
    curl \
    libvips \
    libyaml-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g yarn

# Install Rails
RUN gem install rails

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . /frens-app

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expose port 3000
EXPOSE 3000

# Start the Rails server
ENTRYPOINT ["entrypoint.sh"]