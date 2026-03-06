#!/usr/bin/env bash
# Index a reference genome for minimap2 HiFi alignment.
# Usage: bash 02_index_ref.sh

# --- Configuration ---
# Reference genome FASTA
REF="/path/to/reference.fasta"

# Output index file
INDEX="/path/to/reference.mmi"

# Preset (map-hifi for PacBio HiFi, map-ont for Nanopore)
PRESET="map-hifi"
# ---------------------

minimap2 -x "$PRESET" -d "$INDEX" "$REF"
