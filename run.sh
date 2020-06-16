#!/usr/bin/env bash
module load slurm-drmaa/1.0.7

output_dir=$1
wkdir=$(pwd)

resources="/data/ref_data/gatk/GRCh37.75/"
input_location="/projects/wp2/nobackup/CGU_2019_5_Twist/200320_NDX550407_RUO_0007_AH5YFMAFX2"
data_location="/projects/wp4/nobackup/workspace/joel_test/pgx_module"
ref_location="/data/ref_genomes/bcbio-nextgen/gatk"

cp data/example_config.yaml $output_dir/config.yaml
echo "run_location: $wkdir" >> $output_dir/config.yaml

cd $output_dir

snakemake -p --drmaa "-A wp4 -s -p core -t {cluster.time} -n {cluster.n} " \
	-s ${wkdir}/Snakefile \
	 --use-singularity \
	 --singularity-args \
	"--bind $resources --bind $input_location --bind $data_location --bind $ref_location" \
	--cluster-config ${wkdir}/cluster.json \
	--rerun-incomplete \
	--jobs 1
