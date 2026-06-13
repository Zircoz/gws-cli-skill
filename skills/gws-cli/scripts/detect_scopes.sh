#!/usr/bin/env bash
# detect_scopes.sh — Detect which Google Workspace services are authorized
# Outputs a JSON object like: {"gmail": true, "calendar": false, ...}
#
# Strategy (in order):
#   1. Read the stored OAuth token file and parse granted scopes
#   2. Fallback: make lightweight probe API calls per service

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

# Possible token file locations (gws stores credentials in one of these)
find_token_file() {
  local candidates=(
    "$HOME/.config/gws/token.json"
    "$HOME/.gws/token.json"
    "${XDG_CONFIG_HOME:-$HOME/.config}/gws/token.json"
    "$HOME/.config/googleworkspace/cli/token.json"
  )
  for f in "${candidates[@]}"; do
    if [[ -f "$f" ]]; then
      echo "$f"
      return 0
    fi
  done
  return 1
}

# Check if a scope string is present in the token file's scope list
scope_in_token() {
  local token_file="$1"
  local pattern="$2"
  grep -qi "$pattern" "$token_file" 2>/dev/null
}

# Probe a service with a lightweight read call. Returns 0 if authorized, 1 if not.
probe_service() {
  local service="$1"
  local probe_cmd="$2"
  local output
  output=$(timeout 5 bash -c "$probe_cmd" 2>&1) || true
  # Auth errors look like: "insufficient_scope", "PERMISSION_DENIED", "401", "403"
  if echo "$output" | grep -qiE "insufficient.scope|PERMISSION_DENIED|401|403|unauthorized|not authorized"; then
    return 1
  fi
  # If we got any structured output (or empty ok response), it's authorized
  if echo "$output" | grep -qiE "^\{|^\[|\"kind\"|emailAddress|summary|id"; then
    return 0
  fi
  # Unknown — treat as unauthorized to be safe
  return 1
}

# ── Main detection ─────────────────────────────────────────────────────────

declare -A RESULTS
SERVICES=(gmail calendar drive sheets docs chat admin)

# Initialize all to false
for svc in "${SERVICES[@]}"; do
  RESULTS[$svc]=false
done

# First: try to read the token file for scope strings
TOKEN_FILE=""
if TOKEN_FILE=$(find_token_file 2>/dev/null); then
  # Gmail scopes contain "gmail" or "mail.google"
  scope_in_token "$TOKEN_FILE" "gmail\|mail\.google" && RESULTS[gmail]=true

  # Calendar scopes contain "calendar"
  scope_in_token "$TOKEN_FILE" "calendar" && RESULTS[calendar]=true

  # Drive scopes contain "drive"
  scope_in_token "$TOKEN_FILE" "drive" && RESULTS[drive]=true

  # Sheets scopes contain "spreadsheets"
  scope_in_token "$TOKEN_FILE" "spreadsheets" && RESULTS[sheets]=true

  # Docs scopes contain "documents"
  scope_in_token "$TOKEN_FILE" "documents" && RESULTS[docs]=true

  # Chat scopes contain "chat"
  scope_in_token "$TOKEN_FILE" "chat" && RESULTS[chat]=true

  # Admin scopes contain "admin" or "directory"
  scope_in_token "$TOKEN_FILE" "admin\|directory" && RESULTS[admin]=true
else
  # Fallback: live probes (slower, but works when token format is opaque)
  echo "# No token file found — using live probes (this may take a few seconds)" >&2

  probe_service "gmail" \
    "gws gmail users getProfile --params '{\"userId\":\"me\"}'" \
    && RESULTS[gmail]=true

  probe_service "calendar" \
    "gws calendar calendarList list --params '{\"maxResults\":1}'" \
    && RESULTS[calendar]=true

  probe_service "drive" \
    "gws drive files list --params '{\"pageSize\":1}'" \
    && RESULTS[drive]=true

  probe_service "sheets" \
    "gws sheets spreadsheets get --params '{\"spreadsheetId\":\"test\"}'" \
    && RESULTS[sheets]=true

  probe_service "docs" \
    "gws docs documents get --params '{\"documentId\":\"test\"}'" \
    && RESULTS[docs]=true

  probe_service "chat" \
    "gws chat spaces list --params '{\"pageSize\":1}'" \
    && RESULTS[chat]=true

  probe_service "admin" \
    "gws reports:directory_v1 users list --params '{\"customer\":\"my_customer\",\"maxResults\":1}'" \
    && RESULTS[admin]=true
fi

# ── Output JSON ────────────────────────────────────────────────────────────

echo "{"
first=true
for svc in "${SERVICES[@]}"; do
  if [[ "$first" == "true" ]]; then
    first=false
  else
    echo ","
  fi
  printf '  "%s": %s' "$svc" "${RESULTS[$svc]}"
done
echo ""
echo "}"
