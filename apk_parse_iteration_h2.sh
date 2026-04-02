#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6"
BUILD="$ROOT/build"
DISC="$HOME/repos/odin_os/artifacts/apk_parse_discovery"

mkdir -p "$ROOT/res/values"

cat > "$ROOT/AndroidManifest.xml" <<'XML'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.amethyst.v6">

    <application>
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>

</manifest>
XML

cat > "$ROOT/res/values/strings.xml" <<'XML'
<resources>
    <string name="app_name">PilgrimV6</string>
</resources>
XML

rm -f "$BUILD/classes.dex" "$BUILD/base.apk" "$ROOT/pilgrim_v6.apk"

javac -source 8 -target 8 -cp "$ANDROID_JAR" -d "$BUILD" \
  "$ROOT/src/com/amethyst/v6/MainActivity.java"

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

echo "H2_BUILD_COMPLETE"
echo "APK=$ROOT/pilgrim_v6.apk"
