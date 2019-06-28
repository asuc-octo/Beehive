FROM ruby:2.5.5-slim
WORKDIR /tmp

RUN apt update \
 && apt install -y dirmngr gnupg apt-transport-https \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 \
 && echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list \
 && echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger stretch main" >> /etc/apt/sources.list.d/passenger.list \
 && apt update \
 && apt install -y \
                   nodejs \
                   libpq-dev \
                   build-essential \
                   apache2-dev \
                   libapache2-mod-passenger \
 && apt -t stretch-backports install -y libapache2-mod-shib

COPY Gemfile* ./
RUN bundle check || bundle install --jobs 4 --without development test

COPY . /application
WORKDIR /application
ENV RAILS_ENV=production
ENV PORT=80
RUN bundle exec rake assets:clean \
 && bundle exec rake assets:precompile

CMD ["bash", "entrypoint.sh"]
