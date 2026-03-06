# Structural Variant Calling Pipeline
# Usage: snakemake --cores <N> --configfile config.yaml

configfile: "config.yaml"

SAMPLES = config["samples"]
REF = config["reference"]
FASTQ_DIR = config["fastq_dir"]
OUT_DIR = config["out_dir"]

# --- Target rule ---
rule all:
    input:
        expand("{out}/merged/{sample}_merged.vcf", out=OUT_DIR, sample=SAMPLES),
        expand("{out}/stats/{sample}.flagstat.txt", out=OUT_DIR, sample=SAMPLES),
        f"{OUT_DIR}/sv_summary.txt"

# --- Index reference ---
rule index_ref:
    input:
        REF
    output:
        REF + ".fai",
        REF.replace(".fasta", ".mmi").replace(".fa", ".mmi")
    params:
        preset = config.get("minimap2_preset", "map-hifi"),
        index = REF.replace(".fasta", ".mmi").replace(".fa", ".mmi")
    shell:
        """
        samtools faidx {input}
        minimap2 -x {params.preset} -d {params.index} {input}
        """

# --- Map reads ---
rule map:
    input:
        fastq = FASTQ_DIR + "/{sample}.fastq",
        index = REF.replace(".fasta", ".mmi").replace(".fa", ".mmi")
    output:
        bam = "{out}/bams/{sample}.sorted.bam",
        bai = "{out}/bams/{sample}.sorted.bam.bai"
    params:
        preset = config.get("minimap2_preset", "map-hifi"),
        threads = config.get("threads", 10)
    shell:
        """
        minimap2 -ax {params.preset} -t {params.threads} {input.index} {input.fastq} \
            | samtools view -bS \
            | samtools sort -o {output.bam}
        samtools index {output.bam}
        """

# --- Alignment stats ---
rule stats:
    input:
        "{out}/bams/{sample}.sorted.bam"
    output:
        "{out}/stats/{sample}.flagstat.txt"
    shell:
        "samtools flagstat {input} > {output}"

# --- Sniffles ---
rule sniffles:
    input:
        bam = "{out}/bams/{sample}.sorted.bam",
        ref = REF
    output:
        "{out}/sniffles/{sample}_sniffles.vcf.gz"
    shell:
        "sniffles --input {input.bam} --vcf {output} --reference {input.ref}"

# --- CuteSV ---
rule cutesv:
    input:
        bam = "{out}/bams/{sample}.sorted.bam",
        ref = REF
    output:
        vcf = "{out}/cutesv/{sample}_cutesv.vcf"
    params:
        outdir = "{out}/cutesv",
        max_cluster_bias_ins = config.get("cutesv_max_cluster_bias_ins", 1000),
        diff_ratio_ins = config.get("cutesv_diff_ratio_ins", 0.9),
        max_cluster_bias_del = config.get("cutesv_max_cluster_bias_del", 1000),
        diff_ratio_del = config.get("cutesv_diff_ratio_del", 0.5)
    shell:
        """
        cuteSV \
            --max_cluster_bias_INS {params.max_cluster_bias_ins} \
            --diff_ratio_merging_INS {params.diff_ratio_ins} \
            --max_cluster_bias_DEL {params.max_cluster_bias_del} \
            --diff_ratio_merging_DEL {params.diff_ratio_del} \
            --genotype \
            {input.bam} {input.ref} {output.vcf} {params.outdir}
        """

# --- SVIM ---
rule svim:
    input:
        bam = "{out}/bams/{sample}.sorted.bam",
        ref = REF
    output:
        "{out}/svim/{sample}_svim/variants.vcf"
    params:
        outdir = "{out}/svim/{sample}_svim",
        min_sv_size = config.get("svim_min_sv_size", 30),
        max_sv_size = config.get("svim_max_sv_size", 1000000),
        min_depth = config.get("svim_min_depth", 2)
    shell:
        """
        svim alignment \
            --min_sv_size {params.min_sv_size} \
            --max_sv_size {params.max_sv_size} \
            --minimum_depth {params.min_depth} \
            --sample {wildcards.sample} \
            {params.outdir} {input.bam} {input.ref}
        """

# --- Filter CuteSV ---
rule filter_cutesv:
    input:
        "{out}/cutesv/{sample}_cutesv.vcf"
    output:
        vcf = "{out}/filtered/{sample}_cutesv_filtered.vcf.gz",
        tbi = "{out}/filtered/{sample}_cutesv_filtered.vcf.gz.tbi"
    params:
        min_qual = config.get("cutesv_min_qual", 20)
    shell:
        """
        bcftools view -e 'INFO/IMPRECISE=1 || QUAL<{params.min_qual}' {input} \
            -Oz -o {output.vcf}
        tabix -p vcf {output.vcf}
        """

# --- Filter SVIM ---
rule filter_svim:
    input:
        "{out}/svim/{sample}_svim/variants.vcf"
    output:
        vcf = "{out}/filtered/{sample}_svim_filtered.vcf.gz",
        tbi = "{out}/filtered/{sample}_svim_filtered.vcf.gz.tbi"
    params:
        min_qual = config.get("svim_min_qual", 15)
    shell:
        """
        bcftools view -i 'QUAL>={params.min_qual}' {input} \
            -Oz -o {output.vcf}
        tabix -p vcf {output.vcf}
        """

# --- Filter Sniffles (size filter) ---
rule filter_sniffles:
    input:
        "{out}/sniffles/{sample}_sniffles.vcf.gz"
    output:
        "{out}/filtered/{sample}_sniffles_filtered.vcf"
    params:
        min_svlen = config.get("min_svlen", 50),
        max_svlen = config.get("max_svlen", 1000000)
    shell:
        """
        bcftools view \
            -i '(SVTYPE="BND" || (abs(INFO/SVLEN) >= {params.min_svlen} && abs(INFO/SVLEN) < {params.max_svlen}))' \
            {input} -Ov -o {output}
        """

# --- Generate SURVIVOR list file ---
rule make_survivor_list:
    input:
        sniffles = "{out}/filtered/{sample}_sniffles_filtered.vcf",
        cutesv   = "{out}/filtered/{sample}_cutesv_filtered.vcf.gz",
        svim     = "{out}/filtered/{sample}_svim_filtered.vcf.gz"
    output:
        "{out}/survivor_lists/{sample}_list.txt"
    run:
        with open(output[0], "w") as f:
            for vcf in [input.sniffles, input.cutesv, input.svim]:
                f.write(vcf + "\n")

# --- Merge with SURVIVOR ---
rule survivor_merge:
    input:
        "{out}/survivor_lists/{sample}_list.txt"
    output:
        "{out}/merged/{sample}_merged.vcf"
    params:
        max_distance  = config.get("survivor_max_distance", 250),
        min_callers   = config.get("survivor_min_callers", 2),
        same_type     = config.get("survivor_same_type", 1),
        same_strand   = config.get("survivor_same_strand", 1),
        estimate_dist = config.get("survivor_estimate_distance", 0),
        min_size      = config.get("survivor_min_size", 50),
        survivor      = config.get("survivor_bin", "SURVIVOR")
    shell:
        """
        {params.survivor} merge {input} \
            {params.max_distance} {params.min_callers} {params.same_type} \
            {params.same_strand} {params.estimate_dist} {params.min_size} \
            {output}
        """

# --- SV Summary ---
rule sv_summary:
    input:
        expand("{out}/merged/{sample}_merged.vcf", out=OUT_DIR, sample=SAMPLES)
    output:
        f"{OUT_DIR}/sv_summary.txt"
    run:
        import subprocess
        with open(output[0], "w") as out:
            out.write("SURVIVOR SV Summary\n\n")
            for vcf in input:
                out.write(f"=== {vcf} ===\n")
                total = subprocess.check_output(
                    f"bcftools view {vcf} | grep -v '^#' | wc -l",
                    shell=True, text=True
                ).strip()
                out.write(f"Total variants: {total}\n")

                sv_types = subprocess.check_output(
                    f"bcftools query -f '%INFO/SVTYPE\\n' {vcf} | sort | uniq -c | sort -nr",
                    shell=True, text=True
                )
                out.write("SV Types:\n" + sv_types + "\n")
