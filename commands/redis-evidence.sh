#!/bin/sh
set -eu
export REDISCLI_AUTH="$REDIS_PASSWORD"
run() { printf '> redis-cli'; printf ' %s' "$@"; printf '\n'; redis-cli --csv "$@"; }
run SET seminar:test:student:9101 'Bharat Yadav'
run GET seminar:test:student:9101
run HSET seminar:test:profile:9101 name 'Bharat Yadav' enrollment_no BT24GCS397 semester 5
run HGETALL seminar:test:profile:9101
run SET seminar:test:student:9101 'Bharat Yadav - semester 6'
run HSET seminar:test:profile:9101 semester 6
run HGETALL seminar:test:profile:9101
test "$(redis-cli --raw HGET seminar:test:profile:9101 semester)" = 6
run DEL seminar:test:student:9101 seminar:test:profile:9101
run EXISTS seminar:test:student:9101 seminar:test:profile:9101
test "$(redis-cli --raw EXISTS seminar:test:student:9101 seminar:test:profile:9101)" = 0
printf '[PASS] Redis string and hash CRUD; deleted keys no longer exist.\n'
