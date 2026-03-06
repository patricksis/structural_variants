#!/usr/bin/env bash
# Generate alignment statistics using samtools and qualimap.
# Usage: bash 04_stats.sh

# --- Configuration ---
# Directory containing sorted BAM files
BAM_DIR="/path/to/bam_dir"

# Output directory for stats
STATS_DIR="/path/to/stats_output"

# Threads for qualimap
THREADS=5

# Java memory for qualimap
JAVA_MEM="16G"
# ---------------------

mkdir -p "$STATS_DIR"

for bam in "${BAM_DIR}"/*.sorted.bam; do
    sample=$(basename "$bam" .sorted.bam)
    echo "Stats: $sample"

    samtools flagstat "$bam" > "${STATS_DIR}/${sample}.flagstat.txt"

    qualimap bamqc \
        -bam "$bam" \
        -outdir "${STATS_DIR}/${sample}_qualimap" \
        -nt "$THREADS" \
        --java-mem-size="$JAVA_MEM"
done
