#!/usr/bin/env bash
# Run LongQC on PacBio HiFi reads using Singularity.
# Usage: bash 01_longqc.sh

# --- Configuration ---
# Directory containing input .fastq files
INPUT_DIR="/path/to/fastq_dir"

# Output directory for LongQC results
OUTPUT_DIR="/path/to/longqc_output"

# LongQC Singularity image
IMAGE="/path/to/longqc.sif"

# Sequencing platform preset (pb-sequel, pb-rsii, ont-ligation, ont-rapid)
PRESET="pb-sequel"
# ---------------------

mkdir -p "$OUTPUT_DIR"

for fastq in "${INPUT_DIR}"/*.fastq; do
    sample=$(basename "$fastq" .fastq)
    echo "Running LongQC: $sample"

    singularity exec \
        -B "${INPUT_DIR}:/input,${OUTPUT_DIR}:/output" \
        "$IMAGE" \
        longQC.py sampleqc \
        -x "$PRESET" \
        -o "/output/${sample}_lqc_out" \
        "/input/$(basename "$fastq")"
done
