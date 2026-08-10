FROM docker.io/library/ruby:3.1.2-slim-bullseye

ARG APP_UID=1000
ARG APP_GID=1000

ENV APP_HOME=/app \
    BUNDLE_APP_CONFIG=/app/tmp/bundle \
    BUNDLE_WITHOUT=development:test \
    HOME=/app/tmp \
    PORT=9294 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    TMPDIR=/app/tmp

WORKDIR ${APP_HOME}

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates libsqlite3-0 nodejs pkg-config \
    && groupadd --gid "${APP_GID}" app \
    && useradd --uid "${APP_UID}" --gid app --home-dir "${APP_HOME}" --shell /usr/sbin/nologin app \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set without "${BUNDLE_WITHOUT}" \
    && bundle install --jobs=4 --retry=3

COPY . .
RUN mkdir -p db log storage tmp \
    && SECRET_KEY_BASE=dummy bundle exec rails assets:precompile \
    && chown -R app:app db log storage tmp

EXPOSE 9294

USER app:app

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "9294"]
