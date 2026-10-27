#!/usr/bin/env bash
# Call structural variants using SVIM.
# Usage: bash 06_svim.sh

# --- Configuration ---
# Directory containing sorted BAM files
BAM_DIR="/path/to/bam_dir"

# Reference genome FASTA
REF="/path/to/reference.fasta"

# Output directory for SVIM results
OUT_DIR="/path/to/svim_output"

# SVIM parameters
MIN_SV_SIZE=30
MAX_SV_SIZE=1000000
PARTITION_MAX_DISTANCE=1000
MINIMUM_DEPTH=2
# ---------------------

mkdir -p "$OUT_DIR"

for bam in "${BAM_DIR}"/*.sorted.bam; do
    sample=$(basename "$bam" .sorted.bam)
    echo "Running SVIM: $sample"

    svim alignment \
        --min_sv_size "$MIN_SV_SIZE" \
        --max_sv_size "$MAX_SV_SIZE" \
        --partition_max_distance "$PARTITION_MAX_DISTANCE" \
        --minimum_depth "$MINIMUM_DEPTH" \
        --sample "$sample" \
        "${OUT_DIR}/${sample}_svim" \
        "$bam" \
        "$REF"
done

# Copy SVIM output to a per-sample file name for downstream filtering
cp "${OUT_DIR}/${sample}_svim/variants.vcf" "${OUT_DIR}/${sample}_svim.vcf"
