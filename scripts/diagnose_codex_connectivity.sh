#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-}"
TARGET_DOMAIN="${2:-api.openai.com}"
CANDIDATE_PORTS="${CANDIDATE_PORTS:-7890 7891 7897 1080 10808 10809 20170 2080 8080 8888 9090}"

echo "== Codex / AI CLI Connectivity Diagnostic: macOS/Linux =="
echo "This script prints proxy, loopback, DNS, target-domain, and optional callback-port diagnostics."
echo "It only uses system-visible settings and localhost ports. It does not read VPN credentials or private VPN configs."
echo "Do not paste tokens, cookies, OAuth codes, or full sensitive callback URLs into issue reports."
echo

echo "== System =="
uname -a || true
date || true
echo

echo "== Target domain =="
echo "$TARGET_DOMAIN"
echo

echo "== Proxy environment =="
( env | grep -i 'proxy' ) || echo "No proxy environment variables found."
echo

echo "== macOS system proxy, when available =="
if command -v scutil >/dev/null 2>&1; then
  scutil --proxy || true
else
  echo "scutil not found or not macOS."
fi
echo

echo "== NO_PROXY check =="
printf 'NO_PROXY=%s\n' "${NO_PROXY:-<empty>}"
printf 'no_proxy=%s\n' "${no_proxy:-<empty>}"
echo "Recommended loopback bypass: localhost,127.0.0.1,::1"
echo

echo "== Local proxy candidate ports =="
for p in $CANDIDATE_PORTS; do
  if command -v lsof >/dev/null 2>&1; then
    if lsof -nP -iTCP:"$p" -sTCP:LISTEN >/dev/null 2>&1; then
      echo "candidate listening: 127.0.0.1:$p"
    fi
  fi
done
echo

echo "== Proxy candidate reachability test =="
if command -v curl >/dev/null 2>&1; then
  for p in $CANDIDATE_PORTS; do
    if lsof -nP -iTCP:"$p" -sTCP:LISTEN >/dev/null 2>&1; then
      echo "-- Testing HTTP proxy candidate 127.0.0.1:$p -> https://$TARGET_DOMAIN"
      if curl -I --proxy "http://127.0.0.1:$p" --connect-timeout 8 "https://$TARGET_DOMAIN" >/dev/null 2>&1; then
        echo "WORKING_HTTP_PROXY=http://127.0.0.1:$p"
        echo "Temporary retry example:"
        echo "HTTPS_PROXY=http://127.0.0.1:$p HTTP_PROXY=http://127.0.0.1:$p NO_PROXY=localhost,127.0.0.1,::1 <FAILED_COMMAND>"
      fi
      echo "-- Testing SOCKS proxy candidate 127.0.0.1:$p -> https://$TARGET_DOMAIN"
      if curl -I --proxy "socks5h://127.0.0.1:$p" --connect-timeout 8 "https://$TARGET_DOMAIN" >/dev/null 2>&1; then
        echo "WORKING_SOCKS_PROXY=socks5h://127.0.0.1:$p"
        echo "Temporary retry example:"
        echo "ALL_PROXY=socks5://127.0.0.1:$p NO_PROXY=localhost,127.0.0.1,::1 <FAILED_COMMAND>"
      fi
    fi
  done
else
  echo "curl not found."
fi
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
  echo "Pass callback port as first arg and target domain as second arg, for example:"
  echo "./diagnose_codex_connectivity.sh 1455 api.openai.com"
  echo
fi

echo "== DNS check =="
if command -v nslookup >/dev/null 2>&1; then
  nslookup "$TARGET_DOMAIN" || true
else
  echo "nslookup not found."
fi
echo

echo "== HTTPS reachability check without explicit proxy =="
if command -v curl >/dev/null 2>&1; then
  curl -I --connect-timeout 10 "https://$TARGET_DOMAIN" 2>&1 | sed -E 's/(Authorization: Bearer )[A-Za-z0-9._-]+/\1<REDACTED>/g' | head -80 || true
else
  echo "curl not found."
fi

echo
echo "== Done =="
