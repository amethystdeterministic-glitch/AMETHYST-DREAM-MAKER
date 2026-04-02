#!/data/data/com.termux/files/usr/bin/bash

OUT=~/data/brca_fetch
mkdir -p "$OUT"

echo "[FETCH] TCGA BRCA"

# expression
wget -O "$OUT/tcga_expr.tsv" \
https://toil.xenahubs.net/download/tcga_RSEM_gene_tpm.gz

gunzip -f "$OUT/tcga_expr.tsv"

# clinical (example — update if needed)
wget -O "$OUT/tcga_clin.tsv" \
https://raw.githubusercontent.com/ucscXena/ucsc-xena-client/master/hostedDatasets/tcga_clinical.tsv

echo "[TCGA FETCH COMPLETE]"
