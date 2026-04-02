#!/data/data/com.termux/files/usr/bin/bash

OUT=~/data/brca_fetch

# Example datasets (expand later)
URLS=(
"https://ftp.ncbi.nlm.nih.gov/geo/series/GSE96nnn/GSE96058/matrix/GSE96058_series_matrix.txt.gz"
)

for url in "${URLS[@]}"; do
    name=$(basename "$url")

    echo "[FETCH] $name"

    wget -O "$OUT/$name" "$url"

    gunzip -f "$OUT/$name"

done

echo "[GEO FETCH COMPLETE]"
