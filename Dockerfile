FROM ruby:2.5.5

# Make a directory in the container
RUN mkdir -p /application 

# Copy Gemfile and Gemfile.lock
COPY . /application

# Change to the application's directory
WORKDIR /application

ENV RAILS_ENV=production
ENV RACK_ENV=production

# Install gems and nodejs, and make entrypoint executable
RUN bundle install --deployment --path /bundle --jobs 4 --without development test \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y nodejs

RUN useradd -m beehive
USER beehive

# Start the application server
ENTRYPOINT ["./entrypoint.sh"]
