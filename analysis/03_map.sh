#!/usr/bin/env bash
# Map HiFi reads to reference and convert to sorted BAM.
# Usage: bash 03_map.sh

# --- Configuration ---
# Minimap2 index
INDEX="/path/to/reference.mmi"

# Directory containing input .fastq files
FASTQ_DIR="/path/to/fastq_dir"

# Output directory for sorted BAMs
BAM_DIR="/path/to/bam_dir"

# Number of threads
THREADS=10

# Preset (map-hifi for PacBio HiFi, map-ont for Nanopore)
PRESET="map-hifi"
# ---------------------

mkdir -p "$BAM_DIR"

for fastq in "${FASTQ_DIR}"/*.fastq; do
    sample=$(basename "$fastq" .fastq)
    echo "Mapping: $sample"

    minimap2 -ax "$PRESET" -t "$THREADS" "$INDEX" "$fastq" \
        | samtools view -bS \
        | samtools sort -o "${BAM_DIR}/${sample}.sorted.bam"

    samtools index "${BAM_DIR}/${sample}.sorted.bam"
done
