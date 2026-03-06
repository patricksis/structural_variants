#!/usr/bin/env bash
# Convert SAM to BAM using samtools.
# NOTE: This step is now integrated into 03_map.sh via piping.
# Kept for reference only.
# Usage: bash 03_sam_bam.sh

# --- Configuration ---
SAM_DIR="/path/to/sam_dir"
BAM_DIR="/path/to/bam_dir"
# ---------------------

mkdir -p "$BAM_DIR"

for sam in "${SAM_DIR}"/*.sam; do
    sample=$(basename "$sam" .sam)
    samtools view -bS "$sam" > "${BAM_DIR}/${sample}.bam"
done
