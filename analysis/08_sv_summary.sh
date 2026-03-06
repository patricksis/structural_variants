#!/usr/bin/env bash
# Summarize SV types and size distributions across VCF files.
# Usage: bash 08_sv_summary.sh

# --- Configuration ---
# Directory containing VCF files to summarize
VCF_DIR="/path/to/vcf_dir"

# Output summary file
OUTPUT="survivor_sv_summary.txt"
# ---------------------

echo "SURVIVOR SV Summary" > "$OUTPUT"
echo "Generated on $(date)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

for vcf in "${VCF_DIR}"/*.vcf; do
    echo "=== $(basename "$vcf") ===" >> "$OUTPUT"

    total=$(bcftools view "$vcf" | grep -v '^#' | wc -l)
    echo "Total variants: $total" >> "$OUTPUT"

    echo "SV Types:" >> "$OUTPUT"
    bcftools query -f '%INFO/SVTYPE\n' "$vcf" | sort | uniq -c | sort -nr >> "$OUTPUT"

    echo "SV Lengths:" >> "$OUTPUT"
    bcftools query -f '%INFO/SVLEN\n' "$vcf" | \
        awk '{
            len = sqrt(($1)^2);
            if (len > 10000000) print ">10Mb";
            else if (len > 1000000) print "1Mb-10Mb";
            else if (len > 100000) print "100kb-1Mb";
            else if (len > 10000) print "10kb-100kb";
            else if (len > 1000) print "1kb-10kb";
            else print "<1kb";
        }' | sort | uniq -c | sort -nr >> "$OUTPUT"

    echo "" >> "$OUTPUT"
done

echo "Summary written to $OUTPUT"
