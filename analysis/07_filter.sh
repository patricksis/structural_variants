#!/usr/bin/env bash
# Filter CuteSV VCFs: remove imprecise calls and low-quality variants.
# Usage: bash 07_filter.sh

# --- Configuration ---
# Directory containing CuteSV VCF files
VCF_DIR="/path/to/cutesv_output"

# Output directory for filtered VCFs
OUT_DIR="/path/to/filtered_output"

# Minimum quality score
MIN_QUAL=20
# ---------------------

mkdir -p "$OUT_DIR"

for vcf in "${VCF_DIR}"/*_cutesv.vcf; do
    sample=$(basename "$vcf" _cutesv.vcf)
    echo "Filtering: $sample"

    bcftools view -e "INFO/IMPRECISE=1 || QUAL<${MIN_QUAL}" "$vcf" \
        -Oz -o "${OUT_DIR}/${sample}_cutesv_filtered.vcf.gz"
    tabix -p vcf "${OUT_DIR}/${sample}_cutesv_filtered.vcf.gz"
done
