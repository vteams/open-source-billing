FROM ruby:2.7.1

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/osb

#RUN apt-get update && apt-get install -y curl sudo mysql-client default-libmysqlclient-dev && curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && sudo apt-get install -y nodejs
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
#RUN apt-get -q update && apt-get -qy install netcat

RUN gem install bundler --no-document

WORKDIR /usr/src/osb


COPY Gemfile* /usr/src/osb/
COPY Gemfile Gemfile.lock ./
COPY vendor/engines ./vendor/engines/


RUN bundle install
COPY . /usr/src/osb




COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY ./docker/web/wait-for-it.sh ./docker/web/wait-for-it.sh
RUN chmod +x ./docker/web/wait-for-it.sh

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
