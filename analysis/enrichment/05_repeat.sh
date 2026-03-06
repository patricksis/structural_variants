#!/usr/bin/env bash
# Extract repeat coordinates from a RepeatMasker GFF into BED format.
# Usage: bash 05_repeat.sh

# --- Configuration ---
REPEAT_GFF="/path/to/repeatmasker.gff"
OUT="repeats.bed"
# ---------------------

cut -f1,4,5,9 "$REPEAT_GFF" > "$OUT"
