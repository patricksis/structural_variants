#!/usr/bin/env bash
# Intersect gene BED with per-SV-type BED files.
# Usage: bash 02_gene_overlap.sh

# --- Configuration ---
GENES_BED="genes.bed"
SV_TYPES=(deletions insertions inversions duplications)
# ---------------------

for sv in "${SV_TYPES[@]}"; do
    bedtools intersect -a "$GENES_BED" -b "${sv}.bed" -wa | cut -f4 | sort | uniq > "genes_OverlappedBy_${sv}.list"
    bedtools intersect -b "$GENES_BED" -a "${sv}.bed" -wa | cut -f4 | sort | uniq > "${sv}_OverlappedBy_genes.list"
done
