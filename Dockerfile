FROM ruby:2.6.4-alpine

WORKDIR /app

RUN apk add --update \
  build-base \
  ruby-dev \
  git \
  postgresql-dev \
  linux-headers \
  nodejs \
  openssh \
  tzdata \
  curl \
  bash \
  less

# heroku
RUN curl https://cli-assets.heroku.com/install.sh | sh

ADD Gemfile* /app/

RUN bundle

CMD ["ash"]
