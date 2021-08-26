# PGX module
This workflow is designed to generate sample-specific report with clinical guidelines dependent on variants detected in a Genomic Medicine Sweden sequencing panel. This specific branch is implemented to be run alongside the [Pomfrey](https://github.com/clinical-genomics-uppsala/pomfrey) somatic pipeline

It is designed to be coupled to an existing pipeline and need to be given the location of analysis ready bam files, path to which is specified in `data/example_config`.

### Setup
```{bash}
git clone https://github.com/clinical-genomics-uppsala/pomfrey
cd pomfrey 
git checkout pomfey_pgx
git clone https://github.com/joelaas/pgx_module
cd pgx_module 
git checkout pgx_pomfrey

cd envs
chmod +x get_cointainers.sh
sudo ./get_containers.sh
```

If superuser permissions are not available, please generate containers on a system with where you have and transfer files:

Set paths in `data/example_congif.yaml`.
The `bam_location` is set to the output pattern of the Pomfrey pipeline and specifies the inputs for this pipeline.
 

### Data
In the data folder, definitions of PGX-haplotypes and clinical giuddelines based on these. 
- **data/guidelines/clinical_guidelines.csv**: Three columns: `Gene`, `Activity`, `Guideline`. The activity, corresponding to [0-2] where 0 represents no expected gene activity and 2 is expected normal function. Guideline is the corresponding clinical guideline.   
- **data/guidelines/haplotype_activity_score.csv**: Two columns: `HAPLOTYPE`, `ACTIVITY_SCORE`. Contains the expected activity of a haplotype where 0 is no function and 1 is normal function.
- **data/guidelines/Interaction_guidelines.csv**: Five columns: `gene1`, `gene2`, `activity_1`, `activity_2`, `guideline`. This file contains guidelines for expected gene functions that interact, such as the interaction between NUDT15 and TPMT.

- **data/genomic_regions/exons_variants_pharmacogenomics_{date}**: Four columns without header: `CHROM`, `START`, `STOP`, `exon_{n}_{gene}`. Used for plotting coverage for QA
- **data/genomic_regions/target_rsid.bed**: Five columns without header: `CHROM`, `START`, `STOP`, `{rsID}`, `{gene_name}`. Variants within known PGX-active haplotypes. Used for plotting and QA
- **data/haplotypes/haplotype_definitions.csv**: Two columns: `ID`, `HAPLOTYPE`. `ID` contains rsIDs that define the haplotype.
- **data/haplotypes/hidden_haplotypes.csv**: Three columns: `Haplotype1`, `Haplotype2`, `desc`. Hidden haplotype combinations with reason why it is hidden.

#### Samples Config
Yaml config file with samples to process and local variables and files for the pipeline. Configfile name has to be ${sequencerun}_config.yaml
For any parameters marked `#Pomfrey parameter` please read [Pomfrey](https://github.com/clinical-genomics-uppsala/pomfrey) instructions.

```
programdir:
    dir: "/path/to/pomfrey/" #Pomfrey parameter

reference:
    ref:   "" #Pomfrey parameter
    bwa:   "" #Pomfrey parameter
    dbsnp: "" #Path to dbsnp.vcf

configCache:
    multiqc: "${PATH_TO_POMFREY}/src/report/multiqc_config.yaml" #Pomfrey parameter
    vep: "" #Pomfrey parameter
    hemato: "" #Pomfrey parameter
    variantlist: "" #Pomfrey parameter

bed:
    bedfile: "" #Pomfrey parameter
    intervals: "" #Pomfrey parameter
    pindel: ""  #Pomfrey parameter
    indelartefact: "" #Pomfrey parameter
    pindelArtefact: ""  #Path to pindel artefact file
    cartool: "" #Pomfrey parameter
    hotspot: "" #Pomfrey parameter
    artefact: "" #Pomfrey parameter
    germline: "" #Pomfrey parameter

CNV:
    PoN: "" #Pomfrey parameter
    bedPoN: "" #Pomfrey parameter
    interval: "" #Pomfrey parameter
    cyto: "" #Pomfrey parameter
    
singularitys:
    cutadapt: ""
    bwa: ""
    fastqc: ""
    cartool: ""
    bcftools: ""
    freebayes: ""
    pisces: ""
    vardict: ""
    gatk4: ""
    pindel: ""
    vep: ""
    recall: ""
    python: ""
    vt: ""
    igv: ""
    multiqc: ""
    gatk3:      "path/to/pgx_module/envs/gatk3.simg" # Please enter full path to singularity images generated
    rmarkdown:  "path/to/pgx_module/envs/rmarkdown.simg" # Please enter full path to singularity images generated
    samtools:   "path/to/pgx_module/envs/samtools.simg" # Please enter full path to singularity images generated
    get_target: "path/to/pgx_module/envs/target_variants_python.simg" # Please enter full path to singularity images generated


cartool:
    cov: "100 200 1000" #Pomfrey parameter

methods:   # The (trust) order of vcfs into ensemble recall
    mutect2: "mutect2"
    vardict: "vardict"
    pisces: "pisces"
    freebayes: "freebayes"

seqID:
    sequencerun: "test"

samples:
    my_sample: "my_sample_R1.fastq"

table_data:
    target_regions:        "data/genomic_regions/exons_variants_pharmacogenomics_18_06_2019_ex_cyp2d6.bed"
    target_rsid:           "data/genomic_regions/target_rsid.bed"
    haplotype_definitions: "data/haplotypes/haplotype_definitions.csv"
    hidden_haplotypes:     "data/haplotypes/hidden_haplotpyes.csv"

clinical_data:
    clinical_guidelines:    "data/guidelines/clinical_guidelines.csv"
    haplotype_activity:     "data/guidelines/haplotype_activity_score.csv"
    interaction_guidelines: "data/guidelines/interaction_guidelines.csv"

## Input location
bam_location: "Results/{sample}_{seqID}/Data/{sample}_{seqID}-dedup.bam"

## Contact information for PGX reports 
name: "Person Persson" # Please enter contact information accordingly
adress: "Gatuvägen stadsplatsen 81, 54321"
mail: "me@mymail.me"
phone: "070 123 45 78"
```

### This was tested using:
+ `Snakemake 6.6.1`
+ _Hg19_ reference genome 
+ _dbsnp_ build 138