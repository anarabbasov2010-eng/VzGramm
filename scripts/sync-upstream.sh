#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="${VZGRAMM_UPSTREAM_URL:-https://github.com/DrKLO/Telegram.git}"
UPSTREAM_REF="${VZGRAMM_UPSTREAM_REF:-master}"
TARGET="${VZGRAMM_UPSTREAM_DIR:-upstream/telegram-android}"

rm -rf "$TARGET"
mkdir -p "$(dirname "$TARGET")"
git clone --depth 1 --branch "$UPSTREAM_REF" "$UPSTREAM_URL" "$TARGET"

echo "VzGramm upstream synchronized into $TARGET"
