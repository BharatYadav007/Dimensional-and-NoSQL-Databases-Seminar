#!/bin/sh
set -eu
export REDISCLI_AUTH="$REDIS_PASSWORD"
run() { printf '> redis-cli'; printf ' %s' "$@"; printf '\n'; redis-cli --csv "$@"; }
run SADD seminar:test:interests NoSQL Databases
run SMEMBERS seminar:test:interests
run SET seminar:test:cache 'cached course result' EX 2
run GET seminar:test:cache
run TTL seminar:test:cache
sleep 3
run EXISTS seminar:test:cache
test "$(redis-cli --raw EXISTS seminar:test:cache)" = 0
run DEL seminar:test:interests
run CONFIG GET appendonly appendfsync save
printf '[PASS] Set data type, cache hit, automatic TTL expiry and AOF configuration.\n'
