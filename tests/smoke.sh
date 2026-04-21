#!/usr/bin/env bash
# tests/smoke.sh
# Integration smoke tests for the dspace-containerization local Docker stack.
#
# Tests the DSpace 7.x REST API (HAL), Solr admin API, and Angular SSR frontend.
# Requires only: bash, curl  (jq is used for richer assertions when available).
#
# Usage:
#   ./tests/smoke.sh
#
# Environment variables (all optional, defaults shown):
#   BACKEND_URL   http://localhost:8080
#   SOLR_URL      http://localhost:8983
#   FRONTEND_URL  http://localhost:4000
#   CURL_TIMEOUT  15

set -uo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"
SOLR_URL="${SOLR_URL:-http://localhost:8983}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:4000}"
CURL_TIMEOUT="${CURL_TIMEOUT:-30}"

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
ERRORS=()

pass() { echo -e "  ${GREEN}PASS${NC}  $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}FAIL${NC}  $1"
  ERRORS+=("$1")
  FAIL=$((FAIL + 1))
}
section() { echo -e "\n${CYAN}━━━ $1 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
info()    { echo -e "       ${YELLOW}↳${NC} $1"; }

# ── Helpers ──────────────────────────────────────────────────────────────────

# Assert that a URL returns the expected HTTP status code.
assert_status() {
  local desc="$1" url="$2" expected="$3"
  local actual
  actual=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$CURL_TIMEOUT" "$url" 2>/dev/null || echo "000")
  if [ "$actual" = "$expected" ]; then
    pass "$desc"
  else
    fail "$desc — expected HTTP $expected, got $actual"
    info "$url"
  fi
}

# Assert that the response body of a URL contains a given string.
assert_body_contains() {
  local desc="$1" url="$2" needle="$3"
  local body
  body=$(curl -s --max-time "$CURL_TIMEOUT" "$url" 2>/dev/null || echo "")
  if echo "$body" | grep -q "$needle"; then
    pass "$desc"
  else
    fail "$desc — '$needle' not found in response body"
    info "$url"
  fi
}

# Assert that the response body does NOT contain a given string.
assert_body_not_contains() {
  local desc="$1" url="$2" needle="$3"
  local body
  body=$(curl -s --max-time "$CURL_TIMEOUT" "$url" 2>/dev/null || echo "")
  if echo "$body" | grep -q "$needle"; then
    fail "$desc — unexpected '$needle' found in response body"
    info "$url"
  else
    pass "$desc"
  fi
}

# POST login and assert we get a JWT token back.
assert_login() {
  local desc="$1" url="$2" user="$3" pass_arg="$4"
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$CURL_TIMEOUT" \
    -X POST "$url" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "user=$user" \
    --data-urlencode "password=$pass_arg" 2>/dev/null || echo "000")
  if [ "$http_code" = "200" ]; then
    pass "$desc"
  else
    fail "$desc — expected 200, got $http_code"
    info "$url"
  fi
}

# ── Backend REST API ──────────────────────────────────────────────────────────
section "Backend REST API  $BACKEND_URL"

assert_status        "HAL root returns 200"                  \
  "$BACKEND_URL/server/api"                                  200

assert_body_contains "HAL root contains _links"              \
  "$BACKEND_URL/server/api"                                  '"_links"'

assert_body_contains "HAL root contains dspaceVersion"       \
  "$BACKEND_URL/server/api"                                  '"dspaceVersion"'

assert_body_contains "HAL root contains dspaceServer URL"    \
  "$BACKEND_URL/server/api"                                  '"dspaceServer"'

assert_status        "Communities endpoint returns 200"      \
  "$BACKEND_URL/server/api/core/communities"                 200

assert_status        "Collections endpoint returns 200"      \
  "$BACKEND_URL/server/api/core/collections"                 200

assert_status        "Authn status endpoint returns 200"     \
  "$BACKEND_URL/server/api/authn/status"                     200

assert_body_contains "Authn status — not authenticated"      \
  "$BACKEND_URL/server/api/authn/status"                     '"authenticated"'

assert_body_not_contains "Authn status — authenticated is false not true" \
  "$BACKEND_URL/server/api/authn/status"                     '"authenticated" : true'

# ── Backend Actuator (Spring Boot health) ────────────────────────────────────
section "Backend Actuator"

# DSpace 7.x reports "UP" (fully healthy) or "UP_WITH_ISSUES" (running, minor issues).
# Both mean the application is operational.  We match the prefix without the closing
# quote so that both values pass.
HEALTH=$(curl -s --max-time "$CURL_TIMEOUT" "$BACKEND_URL/server/actuator/health" 2>/dev/null || echo "")
if echo "$HEALTH" | grep -q '"status":"UP'; then
  pass "Actuator health is UP (or UP_WITH_ISSUES)"
elif [ -n "$HEALTH" ]; then
  fail "Actuator health not UP"
  info "Response: $(echo "$HEALTH" | head -c 200)"
else
  fail "Actuator health endpoint unreachable"
fi

# ── Solr ─────────────────────────────────────────────────────────────────────
section "Solr  $SOLR_URL"

assert_status        "Solr system info returns 200"          \
  "$SOLR_URL/solr/admin/info/system"                         200

assert_body_contains "Solr system info — solr version present" \
  "$SOLR_URL/solr/admin/info/system"                         '"solr-spec-version"'

assert_status        "Solr cores admin returns 200"          \
  "$SOLR_URL/solr/admin/cores"                               200

# DSpace requires four cores: authority, oai, search, statistics
for core in authority oai search statistics; do
  assert_body_contains "Solr core '$core' exists"            \
    "$SOLR_URL/solr/admin/cores"                             "\"$core\""
done

assert_status        "Solr 'search' core status returns 200" \
  "$SOLR_URL/solr/search/admin/ping"                         200

# ── Frontend (Angular SSR) ────────────────────────────────────────────────────
# DSpace Angular SSR renders the full page server-side on first request, which can
# take 20-40 s.  We fetch the page ONCE into a temp file (90 s timeout) and run
# all body assertions against that cached copy to avoid redundant slow renders.
section "Frontend  $FRONTEND_URL"

_FE_BODY=$(mktemp)
_FE_HTTP=$(curl -s -w "%{http_code}" --max-time 90 -o "$_FE_BODY" "$FRONTEND_URL/" 2>/dev/null || echo "000")

if [ "$_FE_HTTP" = "200" ]; then
  pass "Frontend / returns 200"
else
  fail "Frontend / returns 200 — expected HTTP 200, got $_FE_HTTP"
  info "$FRONTEND_URL/"
fi

if grep -q "ds-root" "$_FE_BODY" 2>/dev/null; then
  pass "Frontend / — contains ds-root (DSpace Angular root element)"
else
  fail "Frontend / — contains ds-root — 'ds-root' not found in response body"
  info "$FRONTEND_URL/"
fi

if grep -q "DSpace" "$_FE_BODY" 2>/dev/null; then
  pass "Frontend / — contains DSpace title"
else
  fail "Frontend / — contains DSpace title — 'DSpace' not found in response body"
  info "$FRONTEND_URL/"
fi

if grep -q "ng-error" "$_FE_BODY" 2>/dev/null; then
  fail "Frontend / — no Angular error boundary — 'ng-error' found in response body"
  info "$FRONTEND_URL/"
else
  pass "Frontend / — no Angular error boundary"
fi

rm -f "$_FE_BODY"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAIL" -eq 0 ]; then
  echo -e "  ${GREEN}All ${PASS} tests passed.${NC}"
else
  echo -e "  ${GREEN}${PASS} passed${NC}  ${RED}${FAIL} failed${NC}"
  echo ""
  echo -e "  ${RED}Failed tests:${NC}"
  for err in "${ERRORS[@]}"; do
    echo -e "    ${RED}✗${NC} $err"
  done
fi
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]

