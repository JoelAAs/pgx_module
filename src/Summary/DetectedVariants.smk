
rule DetectedVariants:
    """ Get variants with target rsIDs """
    params:
        target_bed        = load_local(config["table_data"]["target_rsid"]),
        hidden_haplotypes = load_local(config["table_data"]["hidden_haplotypes"]),
        script_location   = config["run_location"]
    input:
        vcf = "work/{seqID}/Results/Haplotypecaller/filtered/annotated/{sample}_{seqID}.vcf"
    output:
        csv = "work/{seqID}/Results/Report/detected_variants/{sample}_{seqID}.csv"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 {params.script_location}/src/Summary/get_target_variants.py \
            --target_bed {params.target_bed} \
            --vcf {input.vcf} \
            --output {output.csv} 
        """