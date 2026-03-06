#!/usr/bin/env bash
# Intersect repeat BED with per-SV-type BED files.
# Usage: bash 06_repeat_overlap.sh

# --- Configuration ---
REPEATS_BED="repeats.bed"
SV_TYPES=(deletions insertions inversions duplications)
# ---------------------

for sv in "${SV_TYPES[@]}"; do
    bedtools intersect -a "$REPEATS_BED" -b "${sv}.bed" -wa | cut -f4 | sort | uniq > "repeats_OverlappedBy_${sv}.list"
    bedtools intersect -b "$REPEATS_BED" -a "${sv}.bed" -wa | cut -f4 | sort | uniq > "${sv}_OverlappedBy_repeats.list"
done
