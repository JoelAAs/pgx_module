
rule SampleTargetList:
    params:
        target_bed = config["table_data"]["target_rsid"]
    input:
        detected_variants = "Results/Pharmacogenomics/Report/detected_variants/{sample}_{seqID}.csv"
    output:
        interval = "Results/Pharmacogenomics/Report/coverage/{sample}_{seqID}_target_interval.list"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 src/Summary/reform_genomic_region.py \
            --target_bed={params.target_bed} \
            --output_file={output.interval} \
            --detected_variants={input.detected_variants}
        """


rule DepthOfTargets:
    params:
        ref        = config["reference_fasta"],
        target_bed = config["table_data"]["target_rsid"]
    input:
        bam      = "Results/Pharmacogenomics/bam/{sample}_{seqID}-dedup.filtered.bam",
        interval = "Results/Pharmacogenomics/Report/coverage/{sample}_{seqID}_target_interval.list"
    output:
        gdf      = "Results/Pharmacogenomics/Report/coverage/{sample}_{seqID}_depth_at_missing.gdf",

    singularity:
        config["singularities"]["gatk3"]
    shell:
        """
        java -jar /usr/GenomeAnalysisTK.jar -T DepthOfCoverage -R {params.ref} -I {input.bam} -o {output.gdf} -L {input.interval}
        """


rule GetPaddedBaits:
    params:
        padding= 100,
        target_bed = config["table_data"]["target_regions"],
    output:
        interval = "Results/Pharmacogenomics/gdf/padded_bait_interval.list"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 src/Summary/reform_genomic_region.py \
            --target_bed={params.target_bed} \
            --output_file={output.interval} \
            --padding={params.padding}
        """


rule DepthOfBaits:
    params:
        ref        = config["reference_fasta"],
        target_bed = config["table_data"]["target_regions"],
        padding = 100
    input:
        bam      = "Results/Pharmacogenomics/bam/{sample}_{seqID}-dedup.filtered.bam",
        interval = "Results/Pharmacogenomics/gdf/padded_bait_interval.list"
    output:
        gdf      = "Results/Pharmacogenomics/gdf/{sample}_{seqID}.gdf",
    singularity:
        config["singularities"]["gatk3"]
    shell:
        """
        # NOTE: does not work with openjdk-11, openjdk-8 works
        java -jar /usr/GenomeAnalysisTK.jar -T DepthOfCoverage -R {params.ref} -I {input.bam} -o {output.gdf} -L {input.interval}
        """