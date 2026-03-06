#!/usr/bin/env bash
# Call structural variants using Sniffles2.
# Usage: bash 04_sniffles.sh

# --- Configuration ---
# Directory containing sorted BAM files
BAM_DIR="/path/to/bam_dir"

# Reference genome FASTA
REF="/path/to/reference.fasta"

# Output directory for VCF files
OUT_DIR="/path/to/sniffles_output"
# ---------------------

mkdir -p "$OUT_DIR"

for bam in "${BAM_DIR}"/*.sorted.bam; do
    sample=$(basename "$bam" .sorted.bam)
    echo "Running Sniffles: $sample"

    sniffles \
        --input "$bam" \
        --vcf "${OUT_DIR}/${sample}_sniffles.vcf.gz" \
        --reference "$REF"
done
