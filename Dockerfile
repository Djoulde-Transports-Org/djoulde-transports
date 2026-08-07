# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.9
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    PATH=/usr/local/bundle/bin:$PATH

WORKDIR /app

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
      ca-certificates \
      curl \
      default-mysql-client \
      libjemalloc2 \
      libvips42 \
      tzdata \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*


FROM base AS build

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y \
      build-essential \
      default-libmysqlclient-dev \
      git \
      libffi-dev \
      libreadline-dev \
      libssl-dev \
      libyaml-dev \
      pkg-config \
      zlib1g-dev \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs 4 --retry 3 \
 && rm -rf "${BUNDLE_PATH}/ruby"/*/cache "${BUNDLE_PATH}/ruby"/*/bundler/gems/*/.git

COPY . .


FROM base AS runtime

RUN groupadd --system --gid 1000 rails \
 && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails

COPY --from=build --chown=rails:rails ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build --chown=rails:rails /app /app

USER 1000:1000

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
