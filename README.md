# Structural Variant Analysis Pipeline

A pipeline for calling and analyzing structural variants (SVs) from long-read sequencing data using multiple SV callers, followed by merging and genomic enrichment analysis.

## Overview

Reads are quality-checked, mapped to a reference genome, and processed through three SV callers (Sniffles2, CuteSV, SVIM). Per-sample calls are filtered and merged across callers using SURVIVOR, then analyzed for enrichment in genomic features (genes, exons, repeats, gene flanking regions).

## Dependencies

- [minimap2](https://github.com/lh3/minimap2)
- [samtools](http://www.htslib.org/)
- [LongQC](https://github.com/rlorigro/LongQC) (via Singularity)
- [Sniffles2](https://github.com/fritzsedlazeck/Sniffles)
- [CuteSV](https://github.com/tjiangHIT/cuteSV)
- [SVIM](https://github.com/eldariont/svim)
- [SURVIVOR](https://github.com/fritzsedlazeck/SURVIVOR)
- [bcftools](https://samtools.github.io/bcftools/)
- [bedtools](https://bedtools.readthedocs.io/)
- [qualimap](http://qualimap.conesalab.org/)
- R: [regioneR](https://bioconductor.org/packages/regioneR/)

## Pipeline Steps

Edit the `# --- Configuration ---` block at the top of each script before running.

### 1. Quality Control
```bash
bash analysis/01_longqc.sh
```
Runs LongQC on raw PacBio HiFi reads via Singularity.

### 2. Index Reference
```bash
bash analysis/02_index_ref.sh
```
Indexes the reference genome for minimap2.

### 3. Map Reads
```bash
bash analysis/03_map.sh
```
Maps HiFi reads to the reference and outputs sorted, indexed BAMs. (SAM → BAM conversion is handled via piping; `03_sam_bam.sh` is kept for reference only.)

### 4. Alignment Statistics
```bash
bash analysis/04_stats.sh
```
Runs `samtools flagstat` and `qualimap bamqc` on each BAM.

### 5. SV Calling
Run all three callers:
```bash
bash analysis/04_sniffles.sh   # Sniffles2
bash analysis/05_cutesv.sh     # CuteSV
bash analysis/06_svim.sh       # SVIM
```

### 6. Filter
```bash
bash analysis/07_filter.sh       # Filter CuteSV calls
bash analysis/07b_svim_filter.sh # Filter SVIM calls
bash analysis/07c_size_filter.sh # Size filter (50bp – 1Mb)
```

### 7. Summarize
```bash
bash analysis/08_sv_summary.sh
```
Reports SV type counts and size distributions per VCF.

### 8. Merge with SURVIVOR
```bash
bash analysis/09_merge_survivor.sh
```
Merges per-caller VCFs per sample using SURVIVOR. Requires a `survivor_list/` directory with one `<sample>_list.txt` per sample listing the VCF paths to merge.

### 9. Convert SVs to BED
Split the merged VCF by SV type, then convert each to BED. Deletions, duplications, and inversions use SVLEN to set the end coordinate. Insertions are written as 1 bp intervals since they don't span reference sequence.
```bash
python3 analysis/enrichment/extract_svtype.py merged.vcf DEL deletions.txt
python3 analysis/enrichment/extract_chr_start_end.py deletions.txt deletions.bed

python3 analysis/enrichment/extract_svtype.py merged.vcf DUP duplications.txt
python3 analysis/enrichment/extract_chr_start_end.py duplications.txt duplications.bed

python3 analysis/enrichment/extract_svtype.py merged.vcf INV inversions.txt
python3 analysis/enrichment/extract_chr_start_end.py inversions.txt inversions.bed

python3 analysis/enrichment/extract_svtype.py merged.vcf INS insertions.txt
python3 analysis/enrichment/extract_chr_start_end_INS.py insertions.txt insertions.bed
```

### 10. Enrichment Analysis
Convert VCFs to BED, then run intersections and permutation tests:
```bash
# Prepare feature BEDs
bash analysis/enrichment/01_gene_bed.sh
bash analysis/enrichment/03_exons.sh
bash analysis/enrichment/05_repeat.sh
bash analysis/enrichment/08_5kb_up_down.sh

# Concatenate all SVs
bash analysis/enrichment/concat_allSVs.sh

# Intersect with features
bash analysis/enrichment/02_gene_overlap.sh
bash analysis/enrichment/04_exon_overlap.sh
bash analysis/enrichment/06_repeat_overlap.sh
bash analysis/enrichment/07_intserect_allsv.sh
bash analysis/enrichment/09_intersect_5kb_up_down.sh

# Permutation enrichment test
Rscript analysis/enrichment/10_overlap_enrichment.R
```

## Input Files

| File | Description |
|------|-------------|
| `*.fastq` | Raw PacBio HiFi reads (one per sample) |
| `reference.fasta` | Reference genome |
| `annotation.gff3` | Gene/exon annotations |
| `repeatmasker.gff` | RepeatMasker output |

## Output Files

Key outputs per sample:
- `<sample>_sniffles.vcf.gz` — Sniffles2 SV calls
- `<sample>_cutesv_filtered.vcf.gz` — Filtered CuteSV calls
- `<sample>_svim_filtered.vcf.gz` — Filtered SVIM calls
- `merged_vcfs/<sample>_merged.vcf` — SURVIVOR-merged calls
- `survivor_sv_summary.txt` — SV type and size summary
- `*_OverlappedBy_*.list` — Enrichment overlap lists
