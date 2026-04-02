#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 11 — WEBHUB V1 (PHONE HOSTING)"
echo "===================================="

WEBHUB_ROOT=~/repos/odin_os/webhub_sites
WEBHUB_PID=~/repos/odin_os/runtime/webhub.pid

mkdir -p $WEBHUB_ROOT
mkdir -p ~/repos/odin_os/runtime

########################################
# CREATE SAMPLE SITE
########################################

cat > $WEBHUB_ROOT/index.html << 'EOS'
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>WebHub</title>
</head>

<body style="background:#0b0f14;color:white;font-family:Arial;text-align:center;padding:40px;">
<h1>WEBHUB LIVE</h1>
<p>Your phone is now hosting this site.</p>
</body>
</html>
EOS

########################################
# START SERVER
########################################

if [ -f "$WEBHUB_PID" ] && ps -p $(cat $WEBHUB_PID) > /dev/null 2>&1; then
  echo "[SKIP] WebHub already running"
else
  echo "[START] WebHub server"

  cd $WEBHUB_ROOT
  nohup python3 -m http.server 8080 > /dev/null 2>&1 &

  echo $! > $WEBHUB_PID

  echo "[OK] WebHub running"
  echo "http://localhost:8080"
fi

echo ""
echo "===================================="
echo "WEBHUB READY"
echo "===================================="

