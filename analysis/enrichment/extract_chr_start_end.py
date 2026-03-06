#!/usr/bin/env python3
# Convert a VCF (tab-separated, no header) to BED format using SVLEN to compute end position.
# Usage: python extract_chr_start_end.py <input.vcf> <output.bed>

import sys, re, pandas as pd

vcf = sys.argv[1]
bed = sys.argv[2]

# read in variants file in tsv format
df = pd.read_csv(vcf, sep = "\t", header = None)

# extract chromsome, POS, ID and Info column
chr_pos_info = df.iloc[:, [0,1,2,7]]

# provide names to columns, this will make filtering easier down the road
chr_pos_info.columns = ["chr", "start", "name", "info"]

# So, I could just extract the "END" inforamation however that is not correct for some of these SVs. So, what we will do is extract the SVLEN information and add it to start POS.

# Function to extract the numeric value
def extract_length(text):
    match = re.search(r"SVLEN=-?(\d+)", text)
    if match:
        return int(match.group(1))  # Extract and convert to integer
    return None  # Return None if no match is found

chr_pos_info['len'] = chr_pos_info['info'].apply(extract_length)


# remove the info column
chr_pos_info.pop("info")

# add start and len columns to get the end column
chr_pos_info["end"] = chr_pos_info["start"] + chr_pos_info["len"]

# remove len column
chr_pos_info.pop("len")

# put the name column to the last
chr_pos_info.insert(3, 'name', chr_pos_info.pop('name'))

# save results to a tsv file
chr_pos_info.to_csv(bed, sep = "\t", index = False, header = False)
