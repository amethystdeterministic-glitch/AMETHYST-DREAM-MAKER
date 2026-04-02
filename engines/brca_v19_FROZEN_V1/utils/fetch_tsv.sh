#!/data/data/com.termux/files/usr/bin/bash

URL=$1
OUT=~/data/brca_raw

mkdir -p "$OUT"

name=$(basename "$URL")

echo "[FETCH TSV] $name"

wget -O "$OUT/$name" "$URL"

echo "[DONE]"
