#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for d in "$ROOT/TMessagesProj" "$ROOT/TMessagesProj_App" "$ROOT/TMessagesProj_AppStandalone"; do
  [ -d "$d" ] || continue
  find "$d" -type f \( -name '*.xml' -o -name '*.java' -o -name '*.kt' \) -print0 |
    xargs -0 -r sed -i -e 's/>Telegram</>VzGramm</g'
done

RES="$ROOT/TMessagesProj/src/main/res"
mkdir -p "$RES/values"
cat > "$RES/values/vzgramm_brand.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="vzgramm_app_name">VzGramm</string>
</resources>
EOF

echo "Applied VzGramm branding overlay"
