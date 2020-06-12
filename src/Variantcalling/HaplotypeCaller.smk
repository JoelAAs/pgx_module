
rule Haplotypecaller:
    params:
        ref   = config["reference_fasta"],
        dbsnp = config["dbsnp"]
    input:
        bam = "Results/Pharmacogenomics/bam/{sample}_{seqID}-dedup.filtered.bam",
        bai = "Results/Pharmacogenomics/bam/{sample}_{seqID}-dedup.filtered.bam.bai"
    output:
        vcf = "Results/Pharmacogenomics/Haplotypecaller/{sample}_{seqID}.vcf"
    singularity:
        config["singularities"]["gatk4"]
    shell:
         """
         gatk HaplotypeCaller \
            -R {params.ref} \
            -I {input.bam} \
            --dbsnp {params.dbsnp} \
            -O {output.vcf}
         """