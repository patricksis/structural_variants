#!/usr/bin/env python3
# Extract SVs of a single type from a VCF into a headerless text file.
# Usage: python3 extract_svtype.py <input.vcf> <SVTYPE> <output.txt>

import sys

def extract_svtype_lines(vcf_file, svtype, output_file):
    with open(vcf_file, 'r') as fin, open(output_file, 'w') as fout:
        for line in fin:
            if line.startswith("#"):
                continue  # skip header
            if f"SVTYPE={svtype}" in line:
                fout.write(line)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 extract_svtype.py input.vcf SVTYPE output.txt")
        sys.exit(1)

    vcf_file = sys.argv[1]
    svtype = sys.argv[2]  # e.g., DEL, DUP, INV, INS
    output_file = sys.argv[3]

    extract_svtype_lines(vcf_file, svtype, output_file)
