#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_URL="${VZGRAMM_UPSTREAM_URL:-https://github.com/DrKLO/Telegram.git}"
UPSTREAM_REF="${VZGRAMM_UPSTREAM_REF:-master}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --recursive --shallow-submodules --depth 1 --branch "$UPSTREAM_REF" "$UPSTREAM_URL" "$TMP/Telegram"

rm -rf "$ROOT/TMessagesProj" "$ROOT/TMessagesProj_App" "$ROOT/TMessagesProj_AppHuawei"        "$ROOT/TMessagesProj_AppHockeyApp" "$ROOT/TMessagesProj_AppStandalone"        "$ROOT/TMessagesProj_AppTests" "$ROOT/TMessagesProj_Modules" "$ROOT/Tools" "$ROOT/buildSrc"
rm -f "$ROOT/settings.gradle" "$ROOT/build.gradle" "$ROOT/gradle.properties" "$ROOT/gradlew" "$ROOT/gradlew.bat"

cp -a "$TMP/Telegram/TMessagesProj" "$ROOT/"
cp -a "$TMP/Telegram/TMessagesProj_App" "$ROOT/"
cp -a "$TMP/Telegram/TMessagesProj_AppHuawei" "$ROOT/"
cp -a "$TMP/Telegram/TMessagesProj_AppHockeyApp" "$ROOT/"
cp -a "$TMP/Telegram/TMessagesProj_AppStandalone" "$ROOT/"
cp -a "$TMP/Telegram/TMessagesProj_AppTests" "$ROOT/"
cp -a "$TMP/Telegram/TMessagesProj_Modules" "$ROOT/"
cp -a "$TMP/Telegram/Tools" "$ROOT/"
cp -a "$TMP/Telegram/buildSrc" "$ROOT/"
cp -a "$TMP/Telegram/gradle" "$ROOT/"
cp "$TMP/Telegram/settings.gradle" "$ROOT/"
cp "$TMP/Telegram/build.gradle" "$ROOT/"
cp "$TMP/Telegram/gradle.properties" "$ROOT/"
cp "$TMP/Telegram/gradlew" "$ROOT/"
cp "$TMP/Telegram/LICENSE" "$ROOT/LICENSE" 2>/dev/null || true

echo "VzGramm upstream Android source imported from $UPSTREAM_REF"
