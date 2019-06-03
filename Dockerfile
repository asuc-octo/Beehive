FROM ruby:2.5.5-alpine
COPY Gemfile* /tmp/
WORKDIR /tmp
RUN apk add --no-cache --progress \
                           nodejs \
                   postgresql-dev \
                       build-base \
 && bundle check || bundle install --jobs 4 --without development test \
 && apk del gcc g++ build-base
COPY . /application
WORKDIR /application
ENV RAILS_ENV=production
RUN bundle exec rake assets:clean \
 && bundle exec rake assets:precompile

CMD ["sh", "entrypoint.sh"]
