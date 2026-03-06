#!/usr/bin/env bash
# Extract gene coordinates from a GFF3 file into BED format.
# Usage: bash 01_gene_bed.sh

# --- Configuration ---
GFF="/path/to/annotation.gff3"
OUT="genes.bed"
# ---------------------

grep -v "^#" "$GFF" | grep -w "gene" | cut -f1,4,5,9 | awk '{print $1, $2, $3, $4}' OFS="\t" > "$OUT"
