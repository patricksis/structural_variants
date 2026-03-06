#!/usr/bin/env bash
# Filter SVIM VCFs by quality score.
# Usage: bash 07b_svim_filter.sh

# --- Configuration ---
# Directory containing SVIM VCF files
VCF_DIR="/path/to/svim_output"

# Output directory for filtered VCFs
OUT_DIR="/path/to/filtered_output"

# Minimum quality score
MIN_QUAL=15
# ---------------------

mkdir -p "$OUT_DIR"

for vcf in "${VCF_DIR}"/*_svim.vcf; do
    sample=$(basename "$vcf" _svim.vcf)
    echo "Filtering: $sample"

    bcftools view -i "QUAL>=${MIN_QUAL}" "$vcf" \
        -Oz -o "${OUT_DIR}/${sample}_svim_filtered.vcf.gz"
    tabix -p vcf "${OUT_DIR}/${sample}_svim_filtered.vcf.gz"
done
