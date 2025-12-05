# syntax=docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# =============================================================================
# Development stage
# =============================================================================
FROM base AS dev

# Install packages needed to build gems and for development
# Includes Playwright dependencies for System Specs
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev libyaml-dev pkg-config \
      nodejs npm \
      # Playwright dependencies
      libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
      libxkbcommon0 libatspi2.0-0t64 libxcomposite1 libxdamage1 \
      libxfixes3 libxrandr2 libgbm1 libasound2t64 libpango-1.0-0 \
      libcairo2 libnss3 libnspr4 libx11-xcb1 && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install JS packages
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Install Playwright browsers for System Specs
RUN pnpm dlx playwright install chromium

COPY . .

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

# =============================================================================
# Production build stage
# =============================================================================
FROM base AS build

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Install packages needed to build gems and Node.js for asset compilation
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config nodejs npm && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install JS packages (needed for DaisyUI)
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# Final stage for app image
FROM base

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
