#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 8 — DISCOVER ALL UI"
echo "===================================="

REG_PATH=~/repos/odin_os/artifacts/registry
REG_FILE=$REG_PATH/UI_REGISTRY.json
AETHER_UI=~/repos/odin_os/aether_ui.html

mkdir -p $REG_PATH

########################################
# DISCOVER HTML FILES
########################################

echo "[SCAN] Searching for UI files..."

find /data/data/com.termux/files/home -type f -name "*.html" 2>/dev/null > /tmp/ui_list.txt

########################################
# BUILD REGISTRY
########################################

echo "{" > $REG_FILE

COUNT=0

while read file; do
  NAME=$(basename "$file" | sed 's/.html//g')

  echo "  \"ui_$COUNT\": {" >> $REG_FILE
  echo "    \"name\": \"$NAME\"," >> $REG_FILE
  echo "    \"url\": \"file://$file\"," >> $REG_FILE
  echo "    \"status\": \"active\"" >> $REG_FILE
  echo "  }," >> $REG_FILE

  COUNT=$((COUNT+1))

done < /tmp/ui_list.txt

# remove last comma safely
sed -i '$ s/,$//' $REG_FILE

echo "}" >> $REG_FILE

echo "[OK] $COUNT UI entries registered"

########################################
# BUILD AETHER UI (DYNAMIC LOADER)
########################################

cat > $AETHER_UI << 'EOS'
<!DOCTYPE html>
<html>
<head>
<title>Aether OS</title>

<style>
body { margin:0; font-family: Arial; background:#0b0f14; color:white; }
#nav { padding:10px; background:#111; display:flex; flex-wrap:wrap; gap:6px; }
button { padding:6px 10px; background:#222; color:white; border:none; cursor:pointer; font-size:12px; }
iframe { width:100%; height:92vh; border:none; background:black; }
</style>

</head>

<body>

<div id="nav"></div>
<iframe id="viewer"></iframe>

<script>
async function loadRegistry() {
  const res = await fetch('file:///data/data/com.termux/files/home/repos/odin_os/artifacts/registry/UI_REGISTRY.json');
  const data = await res.json();

  const nav = document.getElementById("nav");

  Object.keys(data).forEach(key => {
    const app = data[key];

    if (app.status === "active") {
      const btn = document.createElement("button");
      btn.innerText = app.name;

      btn.onclick = () => {
        document.getElementById("viewer").src = app.url;
      };

      nav.appendChild(btn);
    }
  });
}

loadRegistry();
</script>

</body>
</html>
EOS

########################################
# START AETHER SERVER
########################################

cat > ~/bin/aether << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

cd ~/repos/odin_os
nohup python3 -m http.server 9090 > /dev/null 2>&1 &

echo ""
echo "===================================="
echo "AETHER LIVE"
echo "http://localhost:9090/aether_ui.html"
echo "===================================="
EOS

chmod +x ~/bin/aether

echo ""
echo "[DONE] AETHER UI READY"
echo ""
echo "Run:"
echo "  aether"
echo ""
echo "===================================="

