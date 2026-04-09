#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 TENANT_CODE HOSTNAME"
  exit 1
fi

TENANT="$1"
HOST="$2"
SRC_DIR="$(cd "$(dirname "$0")/../k8s/tenant-example" && pwd)"
OUT_DIR="./tenant-${TENANT}"

mkdir -p "$OUT_DIR"
for f in "$SRC_DIR"/*.yaml; do
  base="$(basename "$f")"
  sed \
    -e "s/tenant-lab01/tenant-${TENANT}/g" \
    -e "s/lab01.olaba-lis.com/${HOST}/g" \
    "$f" > "$OUT_DIR/$base"
done

echo "Generated manifests in $OUT_DIR"
