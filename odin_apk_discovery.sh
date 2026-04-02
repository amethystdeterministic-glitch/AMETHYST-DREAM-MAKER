#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6"
BUILD="$ROOT/build"
APK="$ROOT/pilgrim_v6.apk"

log() {
  echo "[ODIN] $1"
}

fail() {
  echo "[ODIN][FAIL] $1"
  exit 1
}

pilgrimite() {
  NAME="$1"
  shift
  "$@" || fail "PILGRIMITE_$NAME FAILED"
  log "PILGRIMITE_$NAME PASS"
}

# =========================
# P0 — ENVIRONMENT CHECK
# =========================
CWD="$(pwd)"
if [[ "$CWD" == "$BUILD"* ]]; then
  fail "P0_ENV: Do not run from inside build directory"
fi

log "START — deterministic build with Pilgrimites"

rm -rf "$BUILD"
mkdir -p "$BUILD"

# =========================
# COMPILE
# =========================
log "Compile"
javac -source 8 -target 8 -cp "$ANDROID_JAR" -d "$BUILD" \
  "$ROOT/src/com/amethyst/v6/MainActivity.java" || fail "compile failed"

pilgrimite P1_COMPILE_OUTPUT test -f "$BUILD/com/amethyst/v6/MainActivity.class"

# =========================
# DEX
# =========================
log "Dex"
d8 --lib "$ANDROID_JAR" --output "$BUILD" \
  "$BUILD/com/amethyst/v6/MainActivity.class" || fail "dex failed"

pilgrimite P2_DEX_EXISTS test -f "$BUILD/classes.dex"

# =========================
# PACKAGE
# =========================
log "Package"
aapt package -f \
  -M "$ROOT/AndroidManifest.xml" \
  -S "$ROOT/res" \
  -I "$ANDROID_JAR" \
  -F "$BUILD/base.apk" || fail "aapt failed"

pilgrimite P3_BASE_APK_EXISTS test -f "$BUILD/base.apk"

# =========================
# ASSEMBLE
# =========================
log "Assemble"
cd "$BUILD"
zip -u base.apk classes.dex || fail "zip failed"

pilgrimite P4_DEX_IN_APK unzip -l base.apk | grep classes.dex >/dev/null

# =========================
# SIGN
# =========================
log "Sign"
apksigner sign \
  --ks ~/.android/debug.keystore \
  --ks-key-alias androiddebugkey \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out "$APK" \
  base.apk || fail "sign failed"

pilgrimite P5_SIGNED_APK_EXISTS test -f "$APK"

# =========================
# VERIFY SIGNATURE
# =========================
pilgrimite P6_SIGNATURE_VALID apksigner verify "$APK"

# =========================
# INSTALL TRIGGER
# =========================
log "Trigger install"
termux-open --content-type application/vnd.android.package-archive "$APK"

log "END — awaiting user observation"
