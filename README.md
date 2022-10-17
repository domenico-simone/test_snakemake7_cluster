# Clustering jobs: test

Test snakemake (>7) for behaviour of submitting workflows on cluster.

## Get dummy datasets

```bash
conda activate seqtk

seqtk sample -s 11 8182-1_S38_L001_R1_001.fastq.gz 10000 | gzip > data/A_R1.fastq.gz
seqtk sample -s 11 8182-1_S38_L001_R2_001.fastq.gz 10000 | gzip > data/A_R2.fastq.gz

seqtk sample -s 11 8182-2_S39_L001_R1_001.fastq.gz 10000 | gzip > data/B_R1.fastq.gz
seqtk sample -s 11 8182-2_S39_L001_R2_001.fastq.gz 10000 | gzip > data/B_R2.fastq.gz
```

## Create conda env

```bash
conda create -n test_snakemake7_cluster \
    -c conda-forge -c bioconda \
    snakemake spades biopython quast
```
