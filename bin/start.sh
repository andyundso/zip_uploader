#!/bin/sh

set -eux

# so SQL server once tells its up only to go down again
# so we wait a little bit and wait again
./bin/wait-for-it.sh sql:1433
sleep 5
./bin/wait-for-it.sh sql:1433

bundle exec rails db:migrate || bundle exec rails db:setup

touch /tmp/debug.log
tail -f /tmp/debug.log &

bundle exec puma
