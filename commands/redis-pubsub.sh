#!/bin/sh
set -eu
export REDISCLI_AUTH="$REDIS_PASSWORD"
log=$(mktemp)
subscriber=''
cleanup() { if [ -n "$subscriber" ]; then kill "$subscriber" 2>/dev/null || true; wait "$subscriber" 2>/dev/null || true; fi; rm -f "$log"; }
trap cleanup EXIT
printf 'Background subscriber: redis-cli --csv SUBSCRIBE seminar:test:announcements\n'
redis-cli --csv SUBSCRIBE seminar:test:announcements > "$log" &
subscriber=$!
ready=0
for attempt in $(seq 1 50); do
    count=$(redis-cli --raw PUBSUB NUMSUB seminar:test:announcements | tail -n 1)
    if [ "$count" -ge 1 ]; then ready=1; break; fi
    sleep 0.1
done
test "$ready" = 1
printf '> redis-cli PUBLISH seminar:test:announcements "NoSQL seminar live message"\n'
redis-cli PUBLISH seminar:test:announcements 'NoSQL seminar live message'
for attempt in $(seq 1 50); do
    if grep -q 'NoSQL seminar live message' "$log"; then break; fi
    sleep 0.1
done
printf '\nActual subscriber output:\n'
cat "$log"
grep -q 'NoSQL seminar live message' "$log"
printf '\n[PASS] A live subscriber received the published message.\n'
