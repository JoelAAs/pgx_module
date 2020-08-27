import re; import glob

### Config
glob_pattern = config["bam_location"].format(seqID=config["seqID"]["sequencerun"])

folders = glob.glob(glob_pattern)
config["samples"] = [re.search(f'/([\w,-]+)_{config["seqID"]["sequencerun"]}', f).groups()[0] for  f in folders]

## Anything that follow this pattern that shouldn't be included? Remove here
try:
    config["samples"].remove("batchQC")
except ValueError:
    pass

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
