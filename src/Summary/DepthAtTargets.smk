
rule SampleTargetList:
    params:
        target_bed = load_local(config["table_data"]["target_rsid"]),
        script_location   = config["run_location"]
    input:
        detected_variants = "work/{seqID}/Results/Report/detected_variants/{sample}_{seqID}.csv",
    output:
        interval = "work/{seqID}/Results/Report/coverage/{sample}_{seqID}_target_interval.list"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 {params.script_location}/src/Summary/reform_genomic_region.py \
            --target_bed={params.target_bed} \
            --output_file={output.interval} \
            --detected_variants={input.detected_variants}
        """


rule DepthOfTargets:
    """ Get read depth of variant locations at wildtrype-called positions """
    params:
        ref        = config["reference_fasta"],
        target_bed = load_local(config["table_data"]["target_rsid"])
    input:
        bam      = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam",
        interval = "work/{seqID}/Results/Report/coverage/{sample}_{seqID}_target_interval.list"
    output:
        gdf      = "work/{seqID}/Results/Report/coverage/{sample}_{seqID}_depth_at_missing.gdf",

    singularity:
        config["singularities"]["gatk3"]
    shell:
        """
        java -jar /usr/GenomeAnalysisTK.jar -T DepthOfCoverage -R {params.ref} -I {input.bam} -o {output.gdf} -L {input.interval}
        """


rule GetPaddedBaits:
    params:
        padding= 100,
        target_bed = load_local(config["table_data"]["target_regions"]),
        script_location   = config["run_location"]
    output:
        interval = "work/{seqID}/Results/gdf/padded_bait_interval.list"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 {params.script_location}/src/Summary/reform_genomic_region.py \
            --target_bed={params.target_bed} \
            --output_file={output.interval} \
            --padding={params.padding}
        """


rule DepthOfBaits:
    """ Get read depth of baits """
    params:
        ref        = config["reference_fasta"],
        target_bed = load_local(config["table_data"]["target_regions"]),
        padding = 100
    input:
        bam      = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam",
        interval = "work/{seqID}/Results/gdf/padded_bait_interval.list"
    output:
        gdf      = "work/{seqID}/Results/gdf/{sample}_{seqID}.gdf",
    singularity:
        config["singularities"]["gatk3"]
    shell:
        """
        # NOTE: does not work with openjdk-11, openjdk-8 works
        java -jar /usr/GenomeAnalysisTK.jar -T DepthOfCoverage -R {params.ref} -I {input.bam} -o {output.gdf} -L {input.interval}
        """