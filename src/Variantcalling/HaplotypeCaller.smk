
rule Haplotypecaller:
    params:
        ref   = config["reference_fasta"],
        dbsnp = config["dbsnp"]
    input:
        bam = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam",
        bai = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam.bai"
    output:
        vcf = "work/{seqID}/Results/Haplotypecaller/{sample}_{seqID}.vcf"
    log:
        "logs/PGX/HaplotypeCaller/{sample}_{seqID}.log"
    singularity:
        config["singularities"]["gatk4"]
    shell:
         """
         gatk HaplotypeCaller \
            -R {params.ref} \
            -I {input.bam} \
            --dbsnp {params.dbsnp} \
            -O {output.vcf} &> {log}
         """