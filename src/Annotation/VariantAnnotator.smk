
rule VariantAnnotator:
    params:
        dbsnp = config["reference"]["dbsnp"],
        ref   = config["reference"]["ref"]
    input:
        vcf = "work/{seqID}/Results/Haplotypecaller/filtered/{sample}_{seqID}.vcf",
        bam = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam"
    output:
        vcf = "work/{seqID}/Results/Haplotypecaller/filtered/annotated/{sample}_{seqID}.vcf",
    log:
        "logs/PGX/VariantAnnotator/{sample}_{seqID}.log"
    singularity:
        config["singularitys"]["gatk4"]
    shell:
        """
        gatk VariantAnnotator \
            -R {params.ref} \
            -V {input.vcf} \
            -I {input.bam} \
            -O {output.vcf} \
            --dbsnp {params.dbsnp} &> {log}
        """