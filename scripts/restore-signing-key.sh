#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY="$ROOT/TMessagesProj/config/release.keystore"
TMP="$ROOT/.vzgramm-signing"
mkdir -p "$ROOT/TMessagesProj/config" "$TMP"

PREV_RUN="$(gh run list --workflow "VzGramm Android" --status success --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)"
if [ -n "$PREV_RUN" ]; then
  rm -rf "$TMP/restore"
  mkdir -p "$TMP/restore"
  if gh run download "$PREV_RUN" --name VzGramm-signing-key --dir "$TMP/restore" >/dev/null 2>&1; then
    FOUND="$(find "$TMP/restore" -type f -name 'release.keystore' | head -n 1 || true)"
    if [ -n "$FOUND" ]; then cp "$FOUND" "$KEY"; fi
  fi
fi

if [ -s "$KEY" ]; then
  if ! keytool -list -keystore "$KEY" -storepass "vzgramm-dev-store" -alias "vzgramm" >/dev/null 2>&1; then
    rm -f "$KEY"
  fi
fi

if [ ! -s "$KEY" ]; then
  keytool -genkeypair -v -keystore "$KEY"     -storepass "vzgramm-dev-store" -keypass "vzgramm-dev-store"     -alias "vzgramm" -keyalg RSA -keysize 2048 -validity 10000     -dname "CN=VzGramm Development, OU=VzGramm, O=VzGramm, L=Baku, ST=Baku, C=AZ"
fi

python3 - <<'PY'
from pathlib import Path
import re
p=Path("gradle.properties")
s=p.read_text()
for key,value in {"RELEASE_KEY_PASSWORD":"vzgramm-dev-store","RELEASE_KEY_ALIAS":"vzgramm","RELEASE_STORE_PASSWORD":"vzgramm-dev-store"}.items():
    s=re.sub(rf"^{key}=.*$", f"{key}={value}", s, flags=re.M)
p.write_text(s)
PY
echo "VzGramm development signing key is ready."
