samples = ["A", "B"]

# all rules are assembly, assembly_qc, rMLST
localrules: all, rmlst_api

rule all:
    input:
        #"results/typing/all_mlst.out",
        expand("results/{sample}/qc/quast/{sample}/report.pdf", sample=samples),
        expand("results/{sample}/sequence_typing/{sample}_rmlst.json", sample=samples)

rule assembly:
    input:
        R1 = "data/{sample}_R1.fastq.gz",
        R2 = "data/{sample}_R2.fastq.gz"
    output:
        final_file = "results/{sample}/assembly/spades/scaffolds.fasta"
    threads: 5
    group:
        "group1"
    params:
        outdir = lambda wildcards, output: output.final_file.replace("/scaffolds.fasta", "")
    # conda:
    #     "envs/mapping.yaml"
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
        pdf = "results/{sample}/qc/quast/{sample}/report.pdf"
    params:
        outdir = lambda wildcards, output: output.pdf.replace("/report.pdf", "")
    group:
        "group1"
    # conda:
    #     "envs/quast.yml"
    threads:
        10
#    log:
#        os.path.join(results_dir, "{sample}/logs/qc/quast/{sample}.log")
    shell:
        """
        quast \
            -o {params.outdir} \
            -l {wildcards.sample} \
            -1 {input.R1} \
            -2 {input.R2} \
            -t {threads} --glimmer \
            {input.assembly}
        """

rule rmlst_api:
    input:
        assembly = rules.assembly.output.final_file,
    output:
        rmlst_json     = "results/{sample}/sequence_typing/{sample}_rmlst.json",
        rmlst_tab      = "results/{sample}/sequence_typing/{sample}_rmlst.tab"
    params:
        outdir = lambda wildcards, output: os.path.split(output.rmlst_json)[0]
    # conda:
    #     "envs/mlst.yml"
    threads:
        1
    log:
        "logs/sequence_typing/rmlst/{sample}.log"
    script:
        "scripts/rmlst.py"
