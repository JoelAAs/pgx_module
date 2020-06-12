# PGX module
This workflow is designed to generate sample-specific report with clinical guidelines dependent on variants detected in a Genomic Medicine Sweden sequencing panel.

It is designed to be coupled to an existing pipeline and need to be given the location of analysis ready bam files, path to which is specified in `data/example_config`.

### Setup
Set paths in `data/example_congif.yaml` for `reference_fasta`
and `dbsnp` to suitable files, as well as `bam_location` to input-pattern to bamfiles.
specify the samples and sequencerun desired.

If using singularity with snakemake please run script `envs/get_containers.sh` 


### This was tested using:
+ `Snakemake 5.6.0`
+ _Hg19_ reference genome 
+ _dbsnp_ build 138