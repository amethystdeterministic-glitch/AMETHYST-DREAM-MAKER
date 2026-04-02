#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 9B — FIX AETHER LOADING"
echo "===================================="

AETHER_UI=~/repos/odin_os/aether_ui.html

########################################
# FIX FETCH PATH (HTTP NOT FILE)
########################################

cat > $AETHER_UI << 'EOS'
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Aether OS</title>

<style>
body {
  margin:0;
  font-family: Arial;
  background:#0b0f14;
  color:white;
}

#header {
  padding:12px;
  background:#111;
  text-align:center;
  font-size:16px;
}

#app_list {
  display:flex;
  overflow-x:auto;
  padding:10px;
  gap:10px;
  background:#0f141b;
}

.app_btn {
  min-width:120px;
  padding:12px;
  background:#222;
  border-radius:10px;
  text-align:center;
  font-size:12px;
}

iframe {
  width:100%;
  height:85vh;
  border:none;
  background:black;
}
</style>

</head>

<body>

<div id="header">AETHER</div>
<div id="app_list"></div>
<iframe id="viewer"></iframe>

<script>
async function loadRegistry() {
  try {
    const res = await fetch('/artifacts/registry/UI_REGISTRY.json');
    const data = await res.json();

    const list = document.getElementById("app_list");

    Object.keys(data).forEach(key => {
      const app = data[key];

      if (app.status === "active") {
        const btn = document.createElement("div");
        btn.className = "app_btn";
        btn.innerText = app.name;

        btn.onclick = () => {
          document.getElementById("viewer").src = app.url;
        };

        list.appendChild(btn);
      }
    });

  } catch (err) {
    document.body.innerHTML = "<h2 style='padding:20px'>ERROR LOADING UI REGISTRY</h2>";
    console.error(err);
  }
}

loadRegistry();
</script>

</body>
</html>
EOS

echo "[OK] Aether UI fixed (HTTP loading)"

echo ""
echo "IMPORTANT:"
echo "Make sure Aether server is running:"
echo "  aether"
echo ""
echo "Then reload:"
echo "  http://localhost:9090/aether_ui.html"
echo "===================================="

