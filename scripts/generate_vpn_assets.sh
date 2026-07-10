#!/bin/sh
#
# Generate static release asset files for VPN usage counters.

set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
MANIFEST="$ROOT_DIR/manifests/vpn-v1.txt"
DIST_DIR="$ROOT_DIR/dist"
CONTENT="Static support asset for hwdsl2 VPN projects. See https://github.com/hwdsl2. Do not download manually."

mkdir -p "$DIST_DIR"

seen_file=$(mktemp)
trap 'rm -f "$seen_file"' EXIT HUP INT TERM

while IFS= read -r asset || [ -n "$asset" ]; do
  [ -n "$asset" ] || continue
  case "$asset" in
    vpn-v1-*) ;;
    *) echo "Invalid asset name: $asset" >&2; exit 1 ;;
  esac
  if grep -Fxq "$asset" "$seen_file"; then
    echo "Duplicate asset name: $asset" >&2
    exit 1
  fi
  printf '%s\n' "$asset" >> "$seen_file"
  printf '%s\n' "$CONTENT" > "$DIST_DIR/$asset"
done < "$MANIFEST"

echo "Generated $(wc -l < "$seen_file" | tr -d ' ') VPN usage assets in $DIST_DIR."
