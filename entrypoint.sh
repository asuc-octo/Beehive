#!/bin/bash
set -e

rm -f /application/tmp/pids/server.pid

bundle exec rake assets:precompile

bundle exec rails server -b 0.0.0.0
