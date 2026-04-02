#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "WEBHUB — ADD DQI ROUTES"
echo "===================================="

SERVER=~/repos/odin_os/core/webhub/server.py

# Backup first
cp $SERVER ${SERVER}.bak

cat > $SERVER << 'PY'
from http.server import SimpleHTTPRequestHandler, HTTPServer
import os

PORT = 9090
ROOT = os.path.expanduser("~/repos/odin_os")

class Handler(SimpleHTTPRequestHandler):

    def do_GET(self):

        # --- DQI LOG ROUTE ---
        if self.path == "/dqi_log":
            log_path = os.path.expanduser("~/dqi_runtime.log")

            if os.path.exists(log_path):
                self.send_response(200)
                self.send_header("Content-type", "text/plain")
                self.end_headers()

                with open(log_path, "r") as f:
                    self.wfile.write(f.read().encode())
            else:
                self.send_response(404)
                self.end_headers()
            return

        # --- DEFAULT FILE SERVE ---
        return super().do_GET()

os.chdir(ROOT)

print(f"[WEBHUB] running on http://localhost:{PORT}")
HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
PY

echo "[OK] Routes added"

echo "[RESTART WEBHUB]"
pkill -f webhub
sleep 1

python3 ~/repos/odin_os/core/webhub/server.py &

echo "[DONE]"
