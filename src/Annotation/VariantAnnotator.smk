
rule VariantAnnotator:
    params:
        dbsnp = config["dbsnp"],
        ref   = config["reference_fasta"]
    input:
        vcf = "work/{seqID}/Results/Haplotypecaller/filtered/{sample}_{seqID}.vcf",
        bam = "work/{seqID}/Results/bam/{sample}_{seqID}-dedup.filtered.bam"
    output:
        vcf = "work/{seqID}/Results/Haplotypecaller/filtered/annotated/{sample}_{seqID}.vcf",
    singularity:
        config["singularities"]["gatk4"]
    shell:
        """
        gatk VariantAnnotator \
            -R {params.ref} \
            -V {input.vcf} \
            -I {input.bam} \
            -O {output.vcf} \
            --dbsnp {params.dbsnp}
        """