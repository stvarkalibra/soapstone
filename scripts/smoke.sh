#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${BASE_URL:-http://localhost:8080}"

curl -s "$BASE_URL/healthz" | grep -q ok
echo "OK: healthz"

curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/api/messages" -H 'Content-Type: application/json' -d '{"author":"smoke","text":"smoke test"}' | grep -q 201
echo "OK: dodavanje poruke vraca 201"

curl -s "$BASE_URL/api/messages" | jq -r '.[].author' | grep -q smoke
echo "OK: autor smoke je u listi"

curl -s -o /dev/null -w '%{http_code}' -X POST "$BASE_URL/api/messages" -H 'Content-Type: application/json' -d '{"author":"smoke","text":""}' | grep -q 400
echo "OK: prazan tekst vraca 400"

ID=$(curl -s "$BASE_URL/api/messages" | jq -r '.[0].id')
curl -s -o /dev/null -w '%{http_code}' -X DELETE "$BASE_URL/api/messages/$ID" | grep -q 204
curl -s -o /dev/null -w '%{http_code}' "$BASE_URL/api/messages/$ID" | grep -q 404
echo "OK: brisanje vraca 204, a GET posle toga 404"
