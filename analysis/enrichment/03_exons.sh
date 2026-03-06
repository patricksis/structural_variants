#!/usr/bin/env bash
# Extract exon coordinates from a GFF3 file into BED format.
# Usage: bash 03_exons.sh

# --- Configuration ---
GFF="/path/to/annotation.gff3"
OUT="exons.bed"
# ---------------------

grep -v "^#" "$GFF" | grep -w "exon" | cut -f1,4,5,9 > "$OUT"
