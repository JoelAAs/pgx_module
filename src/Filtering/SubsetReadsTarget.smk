
rule GetPaddedBed:
    params:
        padding= 100,
        target_bed = config["table_data"]["target_regions"],
        script_location = config["run_location"]
    output:
        interval = "Results/bam/padded_bait_interval.bed"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 {params.script_location}/src/Summary/reform_genomic_region.py \
            --target_bed={params.target_bed} \
            --output_file={output.interval} \
            --padding={params.padding} \
            --format='bed'
        """



rule Subset_pharmacogenomic_reads:
    """ Subset analysis ready bam to only regions relevant"""
    input:
        bam   = config["bam_location"],
        index = config["bam_location"] + ".bai",
        region_list = "Results/bam/padded_bait_interval.bed"
    output:
        bam = "Results/bam/{sample}_{seqID}-dedup.filtered.bam",
        bai = "Results/bam/{sample}_{seqID}-dedup.filtered.bam.bai"
    singularity:
        config["singularities"]["samtools"]
    shell:
        """
        samtools view -b {input.bam} -L {input.region_list} > {output.bam}
        samtools index {output.bam}
        """
