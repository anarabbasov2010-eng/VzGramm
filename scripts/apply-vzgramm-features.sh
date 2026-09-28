#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG="$ROOT/TMessagesProj/src/main/java/org/vzgramm/messenger"
mkdir -p "$PKG"

cat > "$PKG/VzGrammFeatures.java" <<'EOF'
package org.vzgramm.messenger;

import android.content.Context;
import android.content.SharedPreferences;

public final class VzGrammFeatures {
    private static final String PREFS = "vzgramm_features";
    private VzGrammFeatures() {}
    private static SharedPreferences p(Context c) { return c.getSharedPreferences(PREFS, Context.MODE_PRIVATE); }
    public static boolean ghost(Context c) { return p(c).getBoolean("ghost", false); }
    public static boolean history(Context c) { return p(c).getBoolean("history", true); }
    public static boolean filters(Context c) { return p(c).getBoolean("filters", true); }
    public static boolean antiRecall(Context c) { return p(c).getBoolean("anti_recall", true); }
    public static boolean streamer(Context c) { return p(c).getBoolean("streamer", false); }
    public static boolean mediaPreview(Context c) { return p(c).getBoolean("media_preview", true); }
    public static void set(Context c, String k, boolean v) { p(c).edit().putBoolean(k, v).apply(); }
}
EOF

cat > "$PKG/VzGrammSettingsActivity.java" <<'EOF'
package org.vzgramm.messenger;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Switch;

public class VzGrammSettingsActivity extends Activity {
    private LinearLayout list;
    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        setTitle("VzGramm Lab");
        ScrollView scroll = new ScrollView(this);
        list = new LinearLayout(this);
        list.setOrientation(LinearLayout.VERTICAL);
        list.setPadding(28, 32, 28, 32);
        scroll.addView(list);
        title("VzGramm Lab");
        info("Independent experimental layer inspired by public AyuGram and exteraGram feature sets. These controls are local to VzGramm.");
        toggle("Ghost mode", "Privacy hook", "ghost", VzGrammFeatures.ghost(this));
        toggle("Message history", "Local history hook", "history", VzGrammFeatures.history(this));
        toggle("Message filters", "Client-side filter hook", "filters", VzGrammFeatures.filters(this));
        toggle("Anti-recall", "Local anti-recall hook", "anti_recall", VzGrammFeatures.antiRecall(this));
        toggle("Streamer mode", "Privacy-oriented UI mode", "streamer", VzGrammFeatures.streamer(this));
        toggle("Enhanced media preview", "Media preview hook", "media_preview", VzGrammFeatures.mediaPreview(this));
        button("Check for update", v -> startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/anarabbasov2010-eng/VzGramm/releases/latest"))));
        info("Updates use the same VzGramm package and development signing identity, so new alpha APKs are intended to install over the previous alpha.");
        setContentView(scroll);
    }
    private void title(String s) { TextView v=t(s,28); v.setGravity(Gravity.CENTER); v.setPadding(0,0,0,18); list.addView(v); }
    private void info(String s) { TextView v=t(s,14); v.setPadding(0,0,0,18); list.addView(v); }
    private TextView t(String s,float size) { TextView v=new TextView(this); v.setText(s); v.setTextSize(size); return v; }
    private void toggle(String title,String summary,String key,boolean checked) {
        Switch v=new Switch(this); v.setText(title+"\n"+summary); v.setTextSize(16); v.setChecked(checked); v.setPadding(0,12,0,12);
        v.setOnCheckedChangeListener((b,value)->VzGrammFeatures.set(this,key,value)); list.addView(v);
    }
    private void button(String s, android.view.View.OnClickListener l) { TextView v=t(s,16); v.setGravity(Gravity.CENTER); v.setPadding(20,24,20,24); v.setOnClickListener(l); list.addView(v); }
}
EOF

MANIFEST="$ROOT/TMessagesProj/src/main/AndroidManifest.xml"
python3 - "$MANIFEST" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
activity='        <activity android:name="org.vzgramm.messenger.VzGrammSettingsActivity" android:exported="false" android:label="VzGramm Lab" />\n'
anchor='        <activity\n            android:name="org.telegram.ui.LaunchActivity"'
if 'VzGrammSettingsActivity' not in s: s=s.replace(anchor, activity+anchor)
p.write_text(s)
PY

SETTINGS="$ROOT/TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java"
python3 - "$SETTINGS" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
needle='        items.add(SettingCell.Factory.of(23, IconBackgroundColors.PURPLE.top, IconBackgroundColors.PURPLE.bottom, R.drawable.settings_features, getString(R.string.TelegramFeatures)));'
insert='        items.add(SettingCell.Factory.of(25, IconBackgroundColors.CYAN.top, IconBackgroundColors.CYAN.bottom, R.drawable.settings_features, "VzGramm Lab", "AyuGram / exteraGram-inspired controls"));\n'+needle
if 'AyuGram / exteraGram-inspired controls' not in s: s=s.replace(needle,insert)
needle2='            case 23: {'
insert2='            case 25:\n                getParentActivity().startActivity(new android.content.Intent(getParentActivity(), org.vzgramm.messenger.VzGrammSettingsActivity.class));\n                break;\n\n'+needle2
if 'case 25:' not in s: s=s.replace(needle2,insert2)
p.write_text(s)
PY

BUILD="$ROOT/TMessagesProj_App/build.gradle"
python3 - "$BUILD" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
needle='    buildTypes {'
block='''    buildTypes {
        preview {
            initWith release
            debuggable false
            minifyEnabled false
            shrinkResources false
            signingConfig signingConfigs.release
        }
'''
if '        preview {' not in s:
    s=s.replace(needle,block)
p.write_text(s)
PY

python3 - "$BUILD" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
needle='        bundleAfat {'
flavor='''        arm64 {
            ndk {
                abiFilters "arm64-v8a"
            }
            ext {
                abiVersionCode = 10
            }
            buildConfigField "boolean", "BUNDLE", "false"
        }
'''
if '        arm64 {' not in s:
    s=s.replace(needle, flavor+needle)
p.write_text(s)
PY

# Allow the lightweight arm64 preview variant through Telegram's original variant filter.
python3 - "$BUILD" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
s=s.replace('if (variant.buildType.name != "release" && !names.contains("afat")) {',
            'if (variant.buildType.name != "release" && variant.buildType.name != "preview" && !names.contains("afat")) {')
p.write_text(s)
PY

echo "Applied VzGramm Lab feature surface."
