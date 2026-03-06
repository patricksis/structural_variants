#!/usr/bin/env bash
# Intersect 5kb up/downstream regions with per-SV-type BED files.
# Usage: bash 09_intersect_5kb_up_down.sh

# --- Configuration ---
FLANK_BED="5_kb_up_down.bed"
ALL_SVS_BED="allSVs.bed"
SV_TYPES=(deletions insertions inversions duplications)
# ---------------------

for sv in "${SV_TYPES[@]}"; do
    bedtools intersect -a "$FLANK_BED" -b "${sv}.bed" -wa | cut -f4 | sort | uniq > "5_kb_up_down_OverlappedBy_${sv}.list"
    bedtools intersect -b "$FLANK_BED" -a "${sv}.bed" -wa | cut -f4 | sort | uniq > "${sv}_OverlappedBy_5_kb_up_down.list"
done

bedtools intersect -a "$FLANK_BED" -b "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > 5_kb_up_down_OverlappedBy_allSVs.list
bedtools intersect -b "$FLANK_BED" -a "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > allSVs_OverlappedBy_5_kb_up_down.list
