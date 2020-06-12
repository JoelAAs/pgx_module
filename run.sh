
resources="/home/joel/Documents/Resourses/GATK/"
input_location="/home/joel/Documents/GMS/pipelines/variant_calling_gms/"
data_location="/home/joel/Documents/GMS/pipelines/pgs_module/"

snakemake --use-singularity --singularity-args \
	"--bind $resources --bind $input_location --bind $data_location"


