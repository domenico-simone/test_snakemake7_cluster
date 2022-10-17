samples = ["A", "B"]

# all rules are assembly, assembly_qc, rMLST
local_rules: rMLST

rule all:
    input:
        "results/typing/all_mlst.out",
        expand("results/{sample}/qc/quast/{sample}/report.pdf"), sample=samples),
        expand("results/sequence_typing/{sample}_rmlst.json", sample=samples)

rule assembly:
    input:
        R1 = "data/{sample}_R1.fastq.gz",
        R2 = "data/{sample}_R2.fastq.gz"
    output:
        final_file = os.path.join(results_dir, "results/{sample}/assembly/spades/scaffolds.fasta")
    threads: 5
    params:
        outdir = lambda wildcards, output: output.final_file.replace("/scaffolds.fasta", "")
    conda:
        "envs/mapping.yaml"
    shell:
        """
        spades.py \
        --isolate \
        -t {threads} \
        -o {params.outdir} \
        -1 {input.R1} \
        -2 {input.R2}
        """

rule assembly_qc:
    input:
        assembly = rules.assembly.output.final_file,
        R1 = "data/{sample}_R1.fastq.gz",
        R2 = "data/{sample}_R2.fastq.gz"
    output:
        pdf = "results/{sample}/qc/quast/{sample}/report.pdf")
    params:
        outdir = lambda wildcards, output: output.pdf.replace("/report.pdf", "")
    conda:
        "envs/quast.yml"
    threads:
        10
    log:
        os.path.join(results_dir, "{sample}/logs/qc/quast/{sample}.log")
    shell:
        """
        quast \
            -o {outdir} \
            -l {sample} \
            input.R1 \
            input.R2 \
            -t {threads} --glimmer \
            {assembly}
        """

rule rmlst_api:
    input:
        assembly = rules.assembly.output.final_file,
    output:
        rmlst_json     = "results/sequence_typing/{sample}_rmlst.json"),
        #rmlst_tab      = "results/sequence_typing/{sample}_rmlst.tab")
    params:
        outdir = lambda wildcards, output: os.path.split(output.rmlst_json)[0]
    # conda:
    #     "envs/mlst.yml"
    threads:
        1
    log:
        os.path.join(results_dir, "{sample}/logs/sequence_typing/rmlst/{sample}.log")
    script:
        "scripts/rmlst.py"