#!/usr/bin/env bash
# Filter SVs by size: keep BNDs and SVs between MIN_SVLEN and MAX_SVLEN.
# Usage: bash 07c_size_filter.sh

# --- Configuration ---
# Directory containing input VCF files
VCF_DIR="/path/to/vcf_dir"

# Output directory for size-filtered VCFs
OUT_DIR="/path/to/filtered_output"

# Size thresholds (bp)
MIN_SVLEN=50
MAX_SVLEN=1000000
# ---------------------

mkdir -p "$OUT_DIR"

for vcf in "${VCF_DIR}"/*.vcf; do
    base=$(basename "$vcf" .vcf)
    echo "Size filtering: $base"

    bcftools view \
        -i "(SVTYPE=\"BND\" || (abs(INFO/SVLEN) >= ${MIN_SVLEN} && abs(INFO/SVLEN) < ${MAX_SVLEN}))" \
        "$vcf" -Ov -o "${OUT_DIR}/${base}.filtered.vcf"
done
