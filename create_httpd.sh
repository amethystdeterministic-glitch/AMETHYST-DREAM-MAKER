#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

cd ~/repos/odin_os

if [ ! -d httpd ]; then
  cargo new httpd --bin
fi
