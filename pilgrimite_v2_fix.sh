#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v2.sh"

echo "[PATCH] Removing unsupported jq lpad()..."

sed -i 's/lpad(3; "0")/./g' "$FILE"

# Replace the ID line cleanly
sed -i 's/id: ($role + "_" + ((.key + 1) | tostring | .))/id: ($role + "_" + ((.key + 1) | tostring))/g' "$FILE"

echo "[PATCH] COMPLETE"
