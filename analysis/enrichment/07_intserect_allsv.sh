#!/usr/bin/env bash
# Intersect all SVs with repeats, genes, and exons.
# Usage: bash 07_intserect_allsv.sh

# --- Configuration ---
ALL_SVS_BED="allSVs.bed"
REPEATS_BED="repeats.bed"
GENES_BED="genes.bed"
EXONS_BED="exons.bed"
# ---------------------

bedtools intersect -a "$REPEATS_BED" -b "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > repeats_OverlappedBy_allSVs.list
bedtools intersect -b "$REPEATS_BED" -a "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > allSVs_OverlappedBy_repeats.list

bedtools intersect -a "$GENES_BED" -b "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > genes_OverlappedBy_allSVs.list
bedtools intersect -b "$GENES_BED" -a "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > allSVs_OverlappedBy_genes.list

bedtools intersect -a "$EXONS_BED" -b "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > exons_OverlappedBy_allSVs.list
bedtools intersect -b "$EXONS_BED" -a "$ALL_SVS_BED" -wa | cut -f4 | sort | uniq > allSVs_OverlappedBy_exons.list
