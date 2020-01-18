FROM ruby:2.3.7-jessie as base

RUN apt-get update -qq && apt-get install -y libicu-dev

RUN gem install bundler -v 1.17.3

RUN mkdir /open-source-billing

WORKDIR /open-source-billing

ARG RAILS_ENV=development
ARG PORT=3000
ENV RACK_ENV=$RAILS_ENV
ENV PORT=$PORT

COPY Gemfile Gemfile.lock ./
COPY vendor/engines ./vendor/engines/
COPY script/entrypoint.sh /usr/bin/

ENTRYPOINT ["entrypoint.sh"]

EXPOSE $PORT

RUN bundle install -j 4

COPY . ./

CMD [ "rails", "s", "-b", "0.0.0.0" ]