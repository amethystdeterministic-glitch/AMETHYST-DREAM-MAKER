#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6"
BUILD="$ROOT/build"
DISC="$HOME/repos/odin_os/artifacts/apk_parse_discovery"

if [ -z "${ANDROID_JAR:-}" ]; then
  echo "ERROR: ANDROID_JAR is not set"
  exit 1
fi

mkdir -p "$ROOT/res/values" "$BUILD"

cat > "$ROOT/AndroidManifest.xml" <<'XML'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.amethyst.v6">

    <application>
        <activity android:name=".MainActivity" />
    </application>

</manifest>
XML

cat > "$ROOT/res/values/strings.xml" <<'XML'
<resources>
    <string name="app_name">PilgrimV6</string>
</resources>
XML

rm -f "$BUILD/classes.dex" "$BUILD/base.apk" "$ROOT/pilgrim_v6.apk"

# Java 8 bytecode (D8 compatible)
javac -source 8 -target 8 -cp "$ANDROID_JAR" -d "$BUILD" \
  "$ROOT/src/com/amethyst/v6/MainActivity.java"

# 🔧 FIX: give D8 the Android runtime
d8 --lib "$ANDROID_JAR" --output "$BUILD" \
  "$BUILD/com/amethyst/v6/MainActivity.class"

aapt package -f \
  -M "$ROOT/AndroidManifest.xml" \
  -S "$ROOT/res" \
  -I "$ANDROID_JAR" \
  -F "$BUILD/base.apk"

(
  cd "$BUILD"
  zip -u base.apk classes.dex
)

apksigner sign \
  --ks "$HOME/.android/debug.keystore" \
  --ks-key-alias androiddebugkey \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "$ROOT/pilgrim_v6.apk" \
  "$BUILD/base.apk"

cat >> "$DISC/ITERATION_LOG.jsonl" <<'JSON'
{"iteration":"H1","change":"minimal manifest + Java8 + D8 --lib android.jar","compile":"pass","dex":"pass","package":"pass","assemble":"pass","sign":"pass","install":"pending","install_result":"pending","status":"awaiting_user_verdict"}
JSON

echo "H1_BUILD_COMPLETE"
echo "APK=$ROOT/pilgrim_v6.apk"
