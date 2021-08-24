
rule GetPaddedBed:
    params:
        padding= 100,
        target_bed = load_local(config["table_data"]["target_regions"]),
        script_location = config["run_location"]
    output:
        interval = "work/{seqID}/Results/bam/padded_bait_interval.bed"
    log:
        "logs/PGX/SubReadsTarget/padded_reads/{seqID}.log"
    singularity:
        config["singularitys"]["get_target"]
    shell:
        """
        python3 {params.script_location}/src/Summary/reform_genomic_region.py \
            --target_bed={params.target_bed} \
            --output_file={output.interval} \
            --padding={params.padding} \
            --format='bed' &> {log}
        """



rule Subset_pharmacogenomic_reads:
    """ Subset analysis ready bam to only regions relevant"""
    input:
        bam   = config["bam_location"],
        index = config["bam_location"] + ".bai",
        region_list = "work/{seqID}/Results/bam/padded_bait_interval.bed"
    output:
        bam = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam",
        bai = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam.bai"
    log:
        "logs/PGX/SubReadsTarget/subset/{sample}_{seqID}.log"
    singularity:
        config["singularitys"]["samtools"]
    shell:
        """
        samtools view -b {input.bam} -L {input.region_list} > {output.bam} &> {log}
        samtools index {output.bam} &>> {log}
        """
