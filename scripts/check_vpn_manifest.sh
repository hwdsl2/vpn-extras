#!/bin/sh
#
# Validate the VPN usage count asset manifest.

set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
MANIFEST="$ROOT_DIR/manifests/vpn-v1.txt"

EXPECTED_COUNT=24
ASSET_RE='^vpn-v1-(headscale|openvpn|wireguard)-(deploy|upgrade)-(amd64|arm64|armv7|other)$'

tmp_manifest=$(mktemp)
tmp_dupes=$(mktemp)
trap 'rm -f "$tmp_manifest" "$tmp_dupes"' EXIT HUP INT TERM

grep -v '^[[:space:]]*$' "$MANIFEST" > "$tmp_manifest"

sort "$tmp_manifest" | uniq -d > "$tmp_dupes"
if [ -s "$tmp_dupes" ]; then
  echo "Duplicate manifest assets:" >&2
  cat "$tmp_dupes" >&2
  exit 1
fi

bad=$(grep -Ev "$ASSET_RE" "$tmp_manifest" || true)
if [ -n "$bad" ]; then
  echo "Malformed manifest asset names:" >&2
  printf '%s\n' "$bad" >&2
  exit 1
fi

count=$(wc -l < "$tmp_manifest" | tr -d ' ')
if [ "$count" != "$EXPECTED_COUNT" ]; then
  echo "Expected $EXPECTED_COUNT VPN usage assets, found $count." >&2
  exit 1
fi

echo "VPN usage manifest OK ($count assets)."
