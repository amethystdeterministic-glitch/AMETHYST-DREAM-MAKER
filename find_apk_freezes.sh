#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"

echo "=== APK FILES ==="
find "$ROOT" -type f \( -name "*.apk" -o -name "*.ap_" \) 2>/dev/null | sort

echo
echo "=== DEX FILES ==="
find "$ROOT" -type f -name "classes.dex" 2>/dev/null | sort

echo
echo "=== MANIFEST FILES ==="
find "$ROOT" -type f -name "AndroidManifest.xml" 2>/dev/null | sort

echo
echo "=== KEY UI STRING HITS ==="
grep -R -n "AMETHYST IS ALIVE" "$ROOT" 2>/dev/null || true
