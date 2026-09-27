#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# The upstream project intentionally keeps its internal Java/Kotlin package names
# unchanged for this first fork stage. We change the public app identity only.
for d in "$ROOT/TMessagesProj" "$ROOT/TMessagesProj_App" "$ROOT/TMessagesProj_AppStandalone"; do
  [ -d "$d" ] || continue
  find "$d" -type f \( -name '*.xml' -o -name '*.java' -o -name '*.kt' \) -print0 |
    xargs -0 -r sed -i \
      -e 's/>Telegram Beta</>VzGramm Beta</g' \
      -e 's/>Telegram</>VzGramm</g' \
      -e 's/Telegram Beta/VzGramm Beta/g'
done

# Use a VzGramm application id while preserving upstream internal classes.
if [ -f "$ROOT/gradle.properties" ]; then
  sed -i \
    -e 's/^APP_PACKAGE=.*/APP_PACKAGE=org.vzgramm.messenger/' \
    -e 's/^IS_PRIVATE=.*/IS_PRIVATE=false/' \
    "$ROOT/gradle.properties"
fi

# Disable upstream-only passkey behavior and official-store links.
BUILD_VARS="$ROOT/TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java"
if [ -f "$BUILD_VARS" ]; then
  sed -i \
    -e 's/public static int APP_ID = [0-9][0-9]*/public static int APP_ID = 0/' \
    -e 's/public static String APP_HASH = ".*";/public static String APP_HASH = "";/' \
    -e 's/public static String SAFETYNET_KEY = ".*";/public static String SAFETYNET_KEY = "";/' \
    -e 's/public static String PLAYSTORE_APP_URL = ".*";/public static String PLAYSTORE_APP_URL = "";/' \
    -e 's/public static String HUAWEI_STORE_URL = ".*";/public static String HUAWEI_STORE_URL = "";/' \
    -e 's/public static String GOOGLE_AUTH_CLIENT_ID = ".*";/public static String GOOGLE_AUTH_CLIENT_ID = "";/' \
    -e 's/public static String HUAWEI_APP_ID = ".*";/public static String HUAWEI_APP_ID = "";/' \
    -e 's/public static boolean SUPPORTS_PASSKEYS = true;/public static boolean SUPPORTS_PASSKEYS = false;/' \
    "$BUILD_VARS"
fi

# Keep one VzGramm launcher identity for every upstream activity-alias.
MANIFEST="$ROOT/TMessagesProj/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  sed -i \
    -e 's/android:icon="@mipmap/icon_[0-9]*_launcher"/android:icon="@mipmap\/ic_launcher"/g' \
    -e 's/android:roundIcon="@mipmap/icon_[0-9]*_launcher_round"/android:roundIcon="@mipmap\/ic_launcher_round"/g' \
    "$MANIFEST"
fi

RES="$ROOT/TMessagesProj/src/main/res"
mkdir -p "$RES/values"
cat > "$RES/values/vzgramm_brand.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="vzgramm_app_name">VzGramm</string>
    <string name="vzgramm_app_name_beta">VzGramm Beta</string>
</resources>
EOF

echo "Applied VzGramm public branding, package id, launcher aliases and fork-safe BuildVars defaults"
