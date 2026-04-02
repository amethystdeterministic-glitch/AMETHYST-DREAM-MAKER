#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT=~/repos/odin_os/amethyst/arm_apk_engine_v6
BUILD=$ROOT/build
SRC=$ROOT/src
ANDROID_JAR=/data/data/com.termux/files/usr/share/java/android.jar

echo "[CLEAN]"
rm -rf $BUILD
mkdir -p $BUILD

echo "[BUILD] compile java"
javac -source 8 -target 8 \
  -classpath $ANDROID_JAR \
  -d $BUILD \
  $(find $SRC -name "*.java")

echo "[BUILD] dex"
d8 --lib $ANDROID_JAR \
   --output $BUILD \
   $(find $BUILD -name "*.class")

echo "[BUILD] package"
aapt package -f \
  --min-sdk-version 16 \
  --target-sdk-version 28 \
  -M $ROOT/AndroidManifest.xml \
  -I $ANDROID_JAR \
  -F $BUILD/base.apk

echo "[BUILD] add classes.dex"
cd $BUILD
zip -u base.apk classes.dex

echo "[BUILD] sign"
apksigner sign \
  --ks ~/.android/debug.keystore \
  --ks-pass pass:android \
  --out $ROOT/pilgrim_v6.apk \
  $BUILD/base.apk

echo "BUILD SUCCESS: $ROOT/pilgrim_v6.apk"
