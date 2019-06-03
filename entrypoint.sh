#!/bin/sh
set -e

rm -f /application/tmp/pids/server.pid

bundle exec puma -C config/puma.rb
