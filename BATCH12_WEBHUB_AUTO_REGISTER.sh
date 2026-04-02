#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 12 — WEBHUB AUTO REGISTER"
echo "===================================="

WEBHUB_ROOT=~/repos/odin_os/webhub_sites
REG_FILE=~/repos/odin_os/artifacts/registry/UI_REGISTRY.json

mkdir -p $WEBHUB_ROOT
mkdir -p ~/repos/odin_os/artifacts/registry

########################################
# ENSURE ROOT INDEX EXISTS
########################################
if [ ! -f "$WEBHUB_ROOT/index.html" ]; then
cat > $WEBHUB_ROOT/index.html << 'EOS'
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>WebHub</title>
</head>
<body style="background:#0b0f14;color:white;font-family:Arial;text-align:center;padding:40px;">
<h1>WEBHUB LIVE</h1>
<p>Your phone is hosting this.</p>
</body>
</html>
EOS
fi

########################################
# BUILD REGISTRY
########################################

echo "{" > $REG_FILE

COUNT=0

########################################
# ADD ROOT WEBHUB
########################################
echo "  \"webhub_root\": {" >> $REG_FILE
echo "    \"name\": \"WebHub\"," >> $REG_FILE
echo "    \"url\": \"http://localhost:8080/index.html\"," >> $REG_FILE
echo "    \"status\": \"active\"" >> $REG_FILE
echo "  }," >> $REG_FILE

########################################
# ADD SUB-SITES
########################################

for dir in $WEBHUB_ROOT/*/; do
  [ -d "$dir" ] || continue

  NAME=$(basename "$dir")

  if [ -f "$dir/index.html" ]; then
    echo "  \"site_$COUNT\": {" >> $REG_FILE
    echo "    \"name\": \"$NAME\"," >> $REG_FILE
    echo "    \"url\": \"http://localhost:8080/$NAME/index.html\"," >> $REG_FILE
    echo "    \"status\": \"active\"" >> $REG_FILE
    echo "  }," >> $REG_FILE

    COUNT=$((COUNT+1))
  fi

done

########################################
# CLEAN JSON (REMOVE LAST COMMA)
########################################
sed -i '$ s/,$//' $REG_FILE
echo "}" >> $REG_FILE

########################################
# CREATE SAMPLE SITE (IF NONE EXIST)
########################################

if [ $COUNT -eq 0 ]; then
  mkdir -p $WEBHUB_ROOT/dashboard

cat > $WEBHUB_ROOT/dashboard/index.html << 'EOS'
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard</title>
</head>
<body style="background:#111;color:white;font-family:Arial;text-align:center;padding:40px;">
<h1>DQI DASHBOARD</h1>
<p>This is your first WebHub app.</p>
</body>
</html>
EOS

  echo "[INFO] Sample site created: dashboard"
fi

########################################
# DONE
########################################

echo "[OK] WebHub auto-registered"
echo ""
echo "Reload Aether:"
echo "http://localhost:9090/aether_ui.html"
echo "===================================="

