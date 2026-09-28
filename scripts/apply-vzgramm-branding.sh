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

# Restore fork-local build metadata removed by upstream import.
python3 - <<'PY'
from pathlib import Path
p=Path("gradle.properties")
s=p.read_text()
defaults={
 "APP_VERSION_CODE":"10000",
 "APP_VERSION_NAME":"1.0.0",
 "APP_PACKAGE":"org.vzgramm.messenger",
 "IS_PRIVATE":"false",
 "RELEASE_KEY_PASSWORD":"vzgramm-dev-key",
 "RELEASE_KEY_ALIAS":"vzgramm",
 "RELEASE_STORE_PASSWORD":"vzgramm-dev-store",
}
import re
for k,v in defaults.items():
    if not re.search(rf"(?m)^{re.escape(k)}=",s):
        s += f"\n{k}={v}"
p.write_text(s)
PY

# Use a VzGramm application id while preserving upstream internal classes.
if [ -f "$ROOT/gradle.properties" ]; then
  sed -i \
    -e 's/^APP_PACKAGE=.*/APP_PACKAGE=org.vzgramm.messenger/' \
    -e 's/^IS_PRIVATE=.*/IS_PRIVATE=false/' \
    "$ROOT/gradle.properties"
fi

# Disable upstream-only passkey behavior and official-store links.
# Do not ship upstream Firebase project credentials in the fork.
rm -f "$ROOT/TMessagesProj/google-services.json"
for gradle_file in "$ROOT/TMessagesProj/build.gradle" "$ROOT/TMessagesProj_App/build.gradle" "$ROOT/TMessagesProj_AppStandalone/build.gradle"; do
  [ -f "$gradle_file" ] || continue
  sed -i "/apply plugin: 'com.google.gms.google-services'/d" "$gradle_file"
done

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
    -e 's|android:icon="@mipmap/icon_[0-9]*_launcher"|android:icon="@mipmap/ic_launcher"|g' \
    -e 's|android:roundIcon="@mipmap/icon_[0-9]*_launcher_round"|android:roundIcon="@mipmap/ic_launcher_round"|g' \
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
