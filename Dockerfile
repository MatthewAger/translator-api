FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /translator-api
COPY Gemfile /translator-api/Gemfile
COPY Gemfile.lock /translator-api/Gemfile.lock
RUN bundle install
COPY . /translator-api

EXPOSE 3000
