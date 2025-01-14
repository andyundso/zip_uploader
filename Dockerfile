FROM ruby:3.4.1-alpine AS base

WORKDIR /work

ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

RUN apk add -U --no-cache build-base freetds-dev npm wget yaml-dev

COPY Gemfile Gemfile.lock .

RUN bundle config build.tiny_tds --with-freetds-dir=/usr && \
    bundle install -j $(nproc)

COPY . .

RUN npm i && \
    bundle exec rails assets:precompile && \
    rm -rf node_modules

##### FINAL

FROM ruby:3.4.1-alpine AS app

ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    FREETDSCONF=/work/freetds.conf

WORKDIR /work

RUN apk add -U --no-cache bash freetds

COPY --from=base /usr/local/bundle /usr/local/bundle
COPY --from=base /work/ /work/

CMD ["/work/bin/start.sh"]
