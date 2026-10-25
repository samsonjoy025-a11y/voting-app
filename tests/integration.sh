#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:8080"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "$COOKIE_JAR"' EXIT

echo "Waiting for the vote service..."

ready=false
for attempt in $(seq 1 30); do
  if curl --silent --fail "$BASE_URL/" >/dev/null; then
    ready=true
    break
  fi
  sleep 2
done

if [ "$ready" != true ]; then
  echo "FAIL: Vote service did not become ready."
  exit 1
fi

echo "Submitting a test vote..."

curl --silent --show-error \
  --cookie "$COOKIE_JAR" \
  --cookie-jar "$COOKIE_JAR" \
  --request POST \
  --data-urlencode "vote=b" \
  "$BASE_URL/" >/dev/null

VOTER_ID="$(awk '$6 == "voter_id" {print $7}' "$COOKIE_JAR")"

if [ -z "$VOTER_ID" ]; then
  echo "FAIL: Could not retrieve the test voter's ID."
  exit 1
fi

echo "Waiting for the worker to save the vote in PostgreSQL..."

for attempt in $(seq 1 30); do
  COUNT="$(docker compose exec -T db \
    psql -U postgres -d postgres -tAc \
    "SELECT COUNT(*) FROM votes WHERE id = '$VOTER_ID' AND vote = 'b';" \
    2>/dev/null || true)"

  if [ "$COUNT" = "1" ]; then
    echo "PASS: Vote submitted and saved in PostgreSQL."
    exit 0
  fi

  sleep 2
done

echo "FAIL: Vote was not saved in PostgreSQL within 60 seconds."
docker compose logs --tail=50 vote worker db redis
exit 1
