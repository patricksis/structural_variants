#!/usr/bin/env bash
# Intersect exon BED with per-SV-type BED files.
# Usage: bash 04_exon_overlap.sh

# --- Configuration ---
EXONS_BED="exons.bed"
SV_TYPES=(deletions insertions inversions duplications)
# ---------------------

for sv in "${SV_TYPES[@]}"; do
    bedtools intersect -a "$EXONS_BED" -b "${sv}.bed" -wa | cut -f4 | sort | uniq > "exons_OverlappedBy_${sv}.list"
    bedtools intersect -b "$EXONS_BED" -a "${sv}.bed" -wa | cut -f4 | sort | uniq > "${sv}_OverlappedBy_exons.list"
done
