#!/bin/sh
set -eu
export REDISCLI_AUTH="$REDIS_PASSWORD"
run() { printf '\nredis-cli'; printf ' %s' "$@"; printf '\n'; redis-cli --raw "$@"; }
printf 'Redis CRUD test uses student 9101; the presentation sample 101 stays available.\n'
run SET seminar:test:student:9101 '{"student_id":9101,"name":"Bharat Yadav","semester":5}'
run GET seminar:test:student:9101
test "$(redis-cli --raw GET seminar:test:student:9101)" = '{"student_id":9101,"name":"Bharat Yadav","semester":5}'
run HSET seminar:test:profile:9101 student_id 9101 name 'Bharat Yadav' enrollment_no BT24GCS397 course 'NoSQL Databases' semester 5
run HGETALL seminar:test:profile:9101
run HSET seminar:test:profile:9101 semester 6
test "$(redis-cli --raw HGET seminar:test:profile:9101 semester)" = 6
run HGETALL seminar:test:profile:9101
run SET seminar:test:student:9101 '{"student_id":9101,"name":"Bharat Yadav","semester":6}'
test "$(redis-cli --raw GET seminar:test:student:9101)" = '{"student_id":9101,"name":"Bharat Yadav","semester":6}'
run DEL seminar:test:student:9101 seminar:test:profile:9101
run EXISTS seminar:test:student:9101 seminar:test:profile:9101
test "$(redis-cli --raw EXISTS seminar:test:student:9101 seminar:test:profile:9101)" = 0
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
printf '\n[PASS] Redis strings, hashes, update, delete, sets, TTL expiry and AOF settings.\n'
