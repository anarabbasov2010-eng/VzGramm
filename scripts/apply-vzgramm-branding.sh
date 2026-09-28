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

# VzGramm visual identity: custom airplane launcher icon and onboarding logo.
RES="$ROOT/TMessagesProj/src/main/res"
mkdir -p "$RES/drawable" "$RES/mipmap-anydpi-v21" "$RES/mipmap-anydpi-v26" "$RES/values"
cat > "$RES/drawable/vzgramm_icon_background.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#17191D" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#24272D" android:pathData="M0,0h108v108h-108z" android:fillAlpha="0.32"/>
</vector>
EOF
cat > "$RES/drawable/vzgramm_icon_foreground.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFF" android:pathData="M22,51.5 L83,25 L66,82 L50,63 L39,76 L42,58 Z"/>
    <path android:fillColor="#17191D" android:pathData="M42,58 L83,25 L50,63 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M50,63 L66,82 L58,58 Z"/>
</vector>
EOF
cat > "$RES/drawable/vzgramm_logo.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="115dp" android:height="35dp" android:viewportWidth="115" android:viewportHeight="35">
    <path android:fillColor="#17191D" android:pathData="M3,17.5 L27,6 L20,29 L14,21 L9,27 L11,19 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M11,19 L27,6 L14,21 Z"/>
    <path android:fillColor="#17191D" android:pathData="M34,10h6v3h-3v12h-3z M43,10h14v4h-10v3h9v4h-9v4h-4z M60,10h11c5,0 8,3 8,7.5S76,25 71,25h-5v-4h4c2,0 3,-1 3,-3.5S72,14 70,14h-5v11h-5z M82,10h10c4,0 7,2 7,6 0,2.5 -1.2,4.3 -3.2,5.2L100,25h-7l-3,-4h-2v4h-6z M88,14v3h3c1.3,0 2,-0.5 2,-1.5S92.3,14 91,14z M102,10h10v4h-6v3h5v4h-5v4h-4z"/>
</vector>
EOF
cat > "$RES/mipmap-anydpi-v26/ic_launcher.xml" <<'EOF'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/vzgramm_icon_background"/>
    <foreground android:drawable="@drawable/vzgramm_icon_foreground"/>
</adaptive-icon>
EOF
cat > "$RES/mipmap-anydpi-v26/ic_launcher_round.xml" <<'EOF'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/vzgramm_icon_background"/>
    <foreground android:drawable="@drawable/vzgramm_icon_foreground"/>
</adaptive-icon>
EOF
cat > "$RES/mipmap-anydpi-v21/ic_launcher.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#17191D" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M22,51.5 L83,25 L66,82 L50,63 L39,76 L42,58 Z"/>
    <path android:fillColor="#17191D" android:pathData="M42,58 L83,25 L50,63 Z"/>
</vector>
EOF
cat > "$RES/mipmap-anydpi-v21/ic_launcher_round.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#17191D" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M22,51.5 L83,25 L66,82 L50,63 L39,76 L42,58 Z"/>
    <path android:fillColor="#17191D" android:pathData="M42,58 L83,25 L50,63 Z"/>
</vector>
EOF
# Replace the Telegram onboarding wordmark with the VzGramm airplane wordmark.
find "$ROOT/TMessagesProj/src/main/java/org/telegram/ui" -type f -name 'IntroActivity.java' -print0 | xargs -0 sed -i 's/R\.drawable\.telegram_logo/R.drawable.vzgramm_logo/g'

# Ensure the actual application entry and every launcher alias use VzGramm icons.
MANIFEST="$ROOT/TMessagesProj/src/main/AndroidManifest.xml"
sed -i 's/android:icon="@mipmap\/[^"]*"/android:icon="@mipmap\/ic_launcher"/g; s/android:roundIcon="@mipmap\/[^"]*"/android:roundIcon="@mipmap\/ic_launcher_round"/g' "$MANIFEST"
