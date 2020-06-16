#!/usr/bin/env bash
module load slurm-drmaa/1.0.7

output_dir=$1
seqid=$2:
wkdir=$(pwd)

#Note: set these paths to your location
resources="/path/to/dbsnp/dir"
input_location="/path/to/sample/bams/"
data_location="/path/to/pgx_module"
ref_location="/path/to/ref_dir"

mkdir -p $output_dir/work/$seqid
cp data/example_config.yaml $output_dir/work/$seqid/config.yaml
echo "run_location: $wkdir" >> $output_dir/work/$seqid/config.yaml
echo "seqID:
        sequencerun: $seqid" >> $output_dir/work/$seqid/config.yaml

cd $output_dir

snakemake -p -r --drmaa " -A wp4 -p core -t {cluster.time} -n {cluster.n} " \
	 -s ${wkdir}/Snakefile \
	 --configfile $seqid/config.yaml \
	 --use-singularity \
	 --singularity-args \
	"--bind $resources --bind $input_location --bind $data_location --bind $ref_location" \
	--cluster-config ${wkdir}/cluster.json \
	--rerun-incomplete \
	--jobs 16
