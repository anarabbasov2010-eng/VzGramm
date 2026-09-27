#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

grep -q '^APP_PACKAGE=org.vzgramm.messenger$' "$ROOT/gradle.properties"

if grep -R -n -E '<string name="AppName(.*)?">Telegram' "$ROOT/TMessagesProj/src/main/res" 2>/dev/null; then
  echo "ERROR: Telegram remains as the primary app name."
  exit 1
fi

if grep -q 'public static boolean SUPPORTS_PASSKEYS = true;' "$ROOT/TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java"; then
  echo "ERROR: official-only passkey support is still enabled."
  exit 1
fi

echo "VzGramm branding verification passed."
