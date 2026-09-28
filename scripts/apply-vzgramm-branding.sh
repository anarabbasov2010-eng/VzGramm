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
  API_ID="${VZGRAMM_API_ID:-0}"
  API_HASH="${VZGRAMM_API_HASH:-}"
  if ! [[ "$API_ID" =~ ^[0-9]+$ ]]; then API_ID=0; fi
  python3 - "$BUILD_VARS" "$API_ID" "$API_HASH" <<'PY'
from pathlib import Path
import re, sys
p=Path(sys.argv[1])
api_id=sys.argv[2]
api_hash=sys.argv[3]
s=p.read_text()
s=re.sub(r'public static int APP_ID = [0-9]+;', f'public static int APP_ID = {api_id};', s)
s=re.sub(r'public static String APP_HASH = ".*?";', lambda m: 'public static String APP_HASH = "' + api_hash.replace('"','\\\"') + '";', s)
p.write_text(s)
PY
  sed -i \
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

# VzGramm visual identity: yellow sticker-style airplane identity.
RES="$ROOT/TMessagesProj/src/main/res"
mkdir -p "$RES/drawable" "$RES/mipmap-anydpi-v21" "$RES/mipmap-anydpi-v26" "$RES/values"

cat > "$RES/drawable/vzgramm_icon_background.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFCC33" android:pathData="M16,0h76a16,16 0,0 1,16 16v76a16,16 0,0 1,-16 16h-76a16,16 0,0 1,-16 -16v-76a16,16 0,0 1,16 -16z"/>
</vector>
EOF
cat > "$RES/drawable/vzgramm_icon_foreground.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#111111" android:pathData="M18,45 L91,25 L67,84 L52,67 L41,79 L42,59 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M23,46 L84,29 L64,77 L52,61 L43,71 L44,56 Z"/>
    <path android:fillColor="#111111" android:pathData="M44,56 L84,29 L52,61 Z"/>
</vector>
EOF
cat > "$RES/drawable/vzgramm_onboarding_logo.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="200dp" android:height="150dp" android:viewportWidth="200" android:viewportHeight="150">
    <path android:fillColor="#111111" android:pathData="M45,73 L157,40 L121,132 L97,105 L78,123 L81,94 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M53,74 L145,47 L117,120 L98,96 L82,112 L84,90 Z"/>
    <path android:fillColor="#111111" android:pathData="M84,90 L145,47 L98,96 Z"/>
</vector>
EOF
cat > "$RES/drawable/vzgramm_notification.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="96dp" android:height="96dp" android:viewportWidth="96" android:viewportHeight="96">
    <path android:fillColor="#FFFFFF" android:pathData="M14,41 L82,20 L60,78 L45,59 L33,71 L35,50 Z"/>
</vector>
EOF
cat > "$RES/drawable/vzgramm_themed.xml" <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#111111" android:pathData="M18,45 L91,25 L67,84 L52,67 L41,79 L42,59 Z"/>
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
    <path android:fillColor="#FFCC33" android:pathData="M16,0h76a16,16 0,0 1,16 16v76a16,16 0,0 1,-16 16h-76a16,16 0,0 1,-16 -16v-76a16,16 0,0 1,16 -16z"/>
    <path android:fillColor="#111111" android:pathData="M18,45 L91,25 L67,84 L52,67 L41,79 L42,59 Z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M23,46 L84,29 L64,77 L52,61 L43,71 L44,56 Z"/>
    <path android:fillColor="#111111" android:pathData="M44,56 L84,29 L52,61 Z"/>
</vector>
EOF
cp "$RES/mipmap-anydpi-v21/ic_launcher.xml" "$RES/mipmap-anydpi-v21/ic_launcher_round.xml"

# Replace the upstream Telegram logo/title and large OpenGL intro visual with VzGramm.
INTRO="$ROOT/TMessagesProj/src/main/java/org/telegram/ui/IntroActivity.java"
python3 - "$INTRO" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
old='''        logoDrawable = context.getResources().getDrawable(R.drawable.telegram_logo).mutate();
        logoDrawable.setBounds(0, dp(8.666f), dp(115), dp(35));
        SpannableStringBuilder ssb = new SpannableStringBuilder(LocaleController.getString(R.string.Page1Title));
        ssb.setSpan(new ImageSpan(logoDrawable), 0, ssb.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        titles[0] = ssb;'''
if old in s:
    s=s.replace(old, '        titles[0] = "VzGramm";')
else:
    s=s.replace('        logoDrawable = context.getResources().getDrawable(R.drawable.vzgramm_logo).mutate();', '        titles[0] = "VzGramm";')
    start=s.find('        SpannableStringBuilder ssb = new SpannableStringBuilder(LocaleController.getString(R.string.Page1Title));')
    if start>=0:
        end=s.find('        titles[0] = ssb;', start)
        if end>=0:
            s=s[:start]+s[end+len('        titles[0] = ssb;'):]
start=s.find('        TextureView textureView = new TextureView(context);')
end=s.find('        viewPager = new ViewPager(context);', start)
if start>=0 and end>=0:
    replacement='''        android.widget.ImageView vzgrammIntroLogo = new android.widget.ImageView(context);
        vzgrammIntroLogo.setImageResource(R.drawable.vzgramm_onboarding_logo);
        vzgrammIntroLogo.setScaleType(android.widget.ImageView.ScaleType.CENTER_INSIDE);
        vzgrammIntroLogo.setAlpha(0.98f);
        frameLayout2.addView(vzgrammIntroLogo, LayoutHelper.createFrame(ICON_WIDTH_DP, ICON_HEIGHT_DP, Gravity.CENTER));
        vzgrammIntroLogo.setScaleX(0.96f);
        vzgrammIntroLogo.setScaleY(0.96f);
        vzgrammIntroLogo.animate().scaleX(1.0f).scaleY(1.0f).setDuration(650).start();

'''
    s=s[:start]+replacement+s[end:]
p.write_text(s)
PY

MANIFEST="$ROOT/TMessagesProj/src/main/AndroidManifest.xml"
sed -i 's/android:icon="@mipmap\/[^"]*"/android:icon="@mipmap\/ic_launcher"/g; s/android:roundIcon="@mipmap\/[^"]*"/android:roundIcon="@mipmap\/ic_launcher_round"/g' "$MANIFEST"

echo "Applied VzGramm sticker-style launcher, onboarding logo/title, and API credential injection."
