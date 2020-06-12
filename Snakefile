configfile: "data/example_config.yaml"

include:    "src/Annotation/VariantAnnotator.smk"
include:    "src/Variantcalling/HaplotypeCaller.smk"
include:    "src/Summary/DetectedVariants.smk"
include:    "src/Summary/DepthAtTargets.smk"
include:    "src/Summary/AppendIDtoGDF.smk"
include:    "src/Report/GeneratePGXReport.smk"
include:    "src/Filtering/VariantFiltration.smk"
include:    "src/Filtering/SubsetReadsTarget.smk"


rule All:
    input:
         expand(
             "Results/Report/{sample}_{seqID}_pgx.html",
                sample=config["samples"],
                seqID=config["seqID"]["sequencerun"])
