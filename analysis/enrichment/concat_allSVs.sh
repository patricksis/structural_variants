#!/usr/bin/env bash
# Concatenate per-SV-type BED files into a single allSVs.bed.
# Usage: bash concat_allSVs.sh

# --- Configuration ---
SV_TYPES=(deletions duplications insertions inversions)
OUT="allSVs.bed"
# ---------------------

cat "${SV_TYPES[@]/%/.bed}" > "$OUT"
