#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-}"

echo "== Codex Connectivity Diagnostic: macOS/Linux =="
echo "This script prints proxy, loopback, DNS, and optional callback-port diagnostics."
echo "Do not paste tokens, cookies, OAuth codes, or full sensitive callback URLs into issue reports."
echo

echo "== System =="
uname -a || true
date || true
echo

echo "== Proxy environment =="
( env | grep -i 'proxy' ) || echo "No proxy environment variables found."
echo

echo "== NO_PROXY check =="
printf 'NO_PROXY=%s\n' "${NO_PROXY:-<empty>}"
printf 'no_proxy=%s\n' "${no_proxy:-<empty>}"
echo "Recommended loopback bypass: localhost,127.0.0.1,::1"
echo

if [[ -n "$PORT" ]]; then
  echo "== Callback port check: $PORT =="
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"$PORT" -sTCP:LISTEN || echo "No listener found on TCP port $PORT."
  else
    echo "lsof not found."
  fi
  echo
  if command -v curl >/dev/null 2>&1; then
    echo "Testing http://127.0.0.1:$PORT/"
    curl -v --max-time 5 "http://127.0.0.1:$PORT/" 2>&1 | sed -E 's/(code|token|state|session)=([^& ]+)/\1=<REDACTED>/g' | head -80 || true
  fi
  echo
else
  echo "== Callback port check skipped =="
  echo "Pass a port as the first argument, for example: ./diagnose_codex_connectivity.sh 1455"
  echo
fi

echo "== DNS check =="
if command -v nslookup >/dev/null 2>&1; then
  nslookup api.openai.com || true
else
  echo "nslookup not found."
fi
echo

echo "== HTTPS reachability check =="
if command -v curl >/dev/null 2>&1; then
  curl -I --connect-timeout 10 https://api.openai.com 2>&1 | sed -E 's/(Authorization: Bearer )[A-Za-z0-9._-]+/\1<REDACTED>/g' | head -80 || true
else
  echo "curl not found."
fi

echo
echo "== Done =="
