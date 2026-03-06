#!/usr/bin/env python3
# Convert an insertion VCF (tab-separated, no header) to BED format.
# Insertions are represented as single-bp intervals (start, start+1).
# Usage: python extract_chr_start_end_INS.py <input.vcf> <output.bed>

import sys, re, pandas as pd

data = sys.argv[1]
bed = sys.argv[2]

# read in insertion data
df = pd.read_csv(data, sep = "\t", header = None)

# extract chr and start column
chr_start_end = df.iloc[:, [0,1]]

# provide names to the column
chr_start_end.columns = ["chr", "start"]

# create a new column by adding 1 to start column
chr_start_end["end"] = chr_start_end["start"] + 1
chr_start_end["ins"] = df[2]

# save
chr_start_end.to_csv(bed, sep = "\t", index = False, header = False)
