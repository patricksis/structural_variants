#!/usr/bin/env bash
# Merge per-caller SV VCFs per sample using SURVIVOR.
# Each sample needs a list file in SURVIVOR_LIST_DIR named <sample>_list.txt
# Usage: bash 09_merge_survivor.sh

# --- Configuration ---
# Path to SURVIVOR binary
SURVIVOR="survivor"

# Directory containing per-sample list files (<sample>_list.txt)
SURVIVOR_LIST_DIR="survivor_list"

# Output directory for merged VCFs
OUT_DIR="merged_vcfs"

# SURVIVOR merge parameters
MAX_DISTANCE=250     # max distance between SVs to merge (bp)
MIN_CALLERS=2        # minimum number of callers that must support an SV
SAME_TYPE=1          # require same SV type (1=yes, 0=no)
SAME_STRAND=1        # require same strand (1=yes, 0=no)
ESTIMATE_DISTANCE=0  # estimate distance by SV size (1=yes, 0=no)
MIN_SIZE=50          # minimum SV size (bp)
# ---------------------

mkdir -p "$OUT_DIR"

for list_file in "${SURVIVOR_LIST_DIR}"/*_list.txt; do
    sample=$(basename "$list_file" _list.txt)
    output_vcf="${OUT_DIR}/${sample}_merged.vcf"

    echo "Merging: $sample"
    "$SURVIVOR" merge "$list_file" \
        "$MAX_DISTANCE" "$MIN_CALLERS" "$SAME_TYPE" "$SAME_STRAND" \
        "$ESTIMATE_DISTANCE" "$MIN_SIZE" \
        "$output_vcf"

    echo "$sample: merged VCF → $output_vcf"
done
