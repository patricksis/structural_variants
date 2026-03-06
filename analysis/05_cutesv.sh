#!/usr/bin/env bash
# Call structural variants using CuteSV.
# Usage: bash 05_cutesv.sh

# --- Configuration ---
# Directory containing sorted BAM files
BAM_DIR="/path/to/bam_dir"

# Reference genome FASTA
REF="/path/to/reference.fasta"

# Output directory for CuteSV results
OUT_DIR="/path/to/cutesv_output"

# CuteSV parameters (tuned for HiFi)
MAX_CLUSTER_BIAS_INS=1000
DIFF_RATIO_MERGING_INS=0.9
MAX_CLUSTER_BIAS_DEL=1000
DIFF_RATIO_MERGING_DEL=0.5
# ---------------------

mkdir -p "$OUT_DIR"

for bam in "${BAM_DIR}"/*.sorted.bam; do
    sample=$(basename "$bam" .sorted.bam)
    echo "Running CuteSV: $sample"

    cuteSV \
        --max_cluster_bias_INS "$MAX_CLUSTER_BIAS_INS" \
        --diff_ratio_merging_INS "$DIFF_RATIO_MERGING_INS" \
        --max_cluster_bias_DEL "$MAX_CLUSTER_BIAS_DEL" \
        --diff_ratio_merging_DEL "$DIFF_RATIO_MERGING_DEL" \
        --genotype \
        "$bam" "$REF" \
        "${OUT_DIR}/${sample}_cutesv.vcf" \
        "$OUT_DIR"
done
