#!/usr/bin/env bash
# Create 5kb upstream and downstream regions for each gene.
# NOTE: After running, manually check for negative coordinates in the output
# and fix them (set to 0) before using in bedtools. Save fixed files as
# 5_kb_upstream_fixed.bed and 5_kb_downstream_fixed.bed.
# Usage: bash 08_5kb_up_down.sh

# --- Configuration ---
GFF="/path/to/annotation.gff3"
FLANK=5000
# ---------------------

grep -v "^#" "$GFF" | grep -w "gene" | grep -v "scaffold" | cut -f1,4,9 > genes_start.bed
grep -v "^#" "$GFF" | grep -w "gene" | grep -v "scaffold" | cut -f1,5,9 > genes_end.bed

awk -v s="$FLANK" '{print $1, $2-s, $2, $3}' OFS="\t" genes_start.bed > 5_kb_upstream.bed
awk -v s="$FLANK" '{print $1, $2, $2+s, $3}' OFS="\t" genes_end.bed > 5_kb_downstream.bed

# After fixing negative coordinates in upstream/downstream files:
cat 5_kb_upstream_fixed.bed 5_kb_downstream_fixed.bed > 5_kb_up_down.bed
