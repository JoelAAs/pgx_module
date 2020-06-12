#!/bin/bash

# Run me in envs folder to get sinuglarities needed
# Please adjust paths of simg location in appropriate config_file


sudo singularity build target_variants_python.simg recepies/get_target_variants
sudo singularity build rmarkdown.simg recepies/Rmarkdown
sudo singularity build samtools.simg recepies/samtools
sudo singularity build gatk3.simg docker://broadinstitute/gatk3:3.8-1
sudo singularity build gatk4.simg docker://broadinstitute/gatk
