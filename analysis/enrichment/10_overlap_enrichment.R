# Permutation test for SV enrichment in genomic features using regioneR.
# Run from the directory containing the input BED files, or set working directory below.
# Install regioneR if needed: BiocManager::install("regioneR")

library(regioneR)

# setwd("/path/to/enrichment_dir")

#-----------------
# Create the dataframe for the genome
#-----------------
genomeDF <- read.csv("fortune_chrs.csv", header = FALSE)
colnames(genomeDF) <- c("chr", "length")

#-----------------
# are SVs enriched in repeats?
#-----------------
svs <- toGRanges("allSVs.filtered.bed")
repeats <- toGRanges("repeats.filtered.bed")

pt_repeats <- permTest(A=svs, ntimes=1000, B=repeats, randomize.function=randomizeRegions, non.overlapping=TRUE, per.chromosome=TRUE, count.once=TRUE, evaluate.function=numOverlaps, genome=genomeDF, mc.cores=30)
summary(pt_repeats)
png(file="repeats_SV_plot.png")
plot(pt_repeats)
dev.off()
#-----------------
# are SVs enriched in 5kb regions up and downstream of genes?
#-----------------
upAndDown <- toGRanges("5_kb_up_down.filtered.sorted.bed")

pt_upAndDown <- permTest(A=svs, ntimes=1000, B=upAndDown, randomize.function=randomizeRegions, non.overlapping=TRUE, per.chromosome=TRUE, count.once=TRUE, evaluate.function=numOverlaps, genome=genomeDF, mc.cores=30)
summary(pt_upAndDown)
png(file="upAndDown_SV_plot.png")
plot(pt_upAndDown)
dev.off()

#-----------------
# are SVs depleted in genes?
#-----------------
genes <- toGRanges("genes.filtered.bed")

pt_genes <- permTest(A=svs, ntimes=1000, B=genes, randomize.function=randomizeRegions, non.overlapping=TRUE, per.chromosome=TRUE, count.once=TRUE, evaluate.function=numOverlaps, genome=genomeDF, mc.cores=30)
summary(pt_genes)
png(file="genes_SV_plot_switch.png")
plot(pt_genes)
dev.off()

#-----------------
# are SVs depleted in exons?
#-----------------
exons <- toGRanges("exons.filtered.bed")

pt_exons <- permTest(A=svs, ntimes=1000, B=exons, randomize.function=randomizeRegions, non.overlapping=TRUE, per.chromosome=TRUE, count.once=TRUE, evaluate.function=numOverlaps, genome=genomeDF, mc.cores=30)
summary(pt_exons)
png(file="exons_SV_plot.png")
plot(pt_exons)
dev.off()
