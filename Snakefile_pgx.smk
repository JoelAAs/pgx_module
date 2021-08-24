import re; import glob
import os

### Config
config["run_location"] = config["programdir"]["dir"] + "/pgx_module"

def load_local(path):
    return f'{config["run_location"]}/{path}'

wildcard_constraints:
    seqID = config["seqID"]["sequencerun"],
    sample = "[[a-zA-Z0-9-_\.]+"


### Include
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
             "work/{seqID}/Results/Report/{sample}_{seqID}_pgx.html",
                sample=config["samples"],
                seqID=config["seqID"]["sequencerun"])
