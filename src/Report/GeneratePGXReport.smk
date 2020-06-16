## NOTE: setting '.libPaths('/lib/rlib')' specific to singularity used

rule GetClinicalGuidelines:
    """ Given detected variants, get possible Haplotype combinations """
    params:
        haplotype_definitions = config["table_data"]["haplotype_definitions"],
        clinical_guidelines   = config["clinical_data"]["clinical_guidelines"],
        haplotype_activity    = config["clinical_data"]["haplotype_activity"],
        hidden_haplotypes     = config["table_data"]["hidden_haplotypes"],
        script_location       = config["run_location"]
    input:
        found_variants  = "Results/Report/detected_variants/{sample}_{seqID}.csv",
    output:
        csv = "Results/Report/detected_variants/possible_diploids/{sample}_{seqID}.csv"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 {params.script_location}/src/Summary/get_possible_diplotypes.py \
            --variant_csv {input.found_variants} \
            --haplotype_definitions {params.haplotype_definitions} \
            --clinical_guidelines {params.clinical_guidelines} \
            --haplotype_activity {params.haplotype_activity} \
            --output {output.csv} \
            --hidden_haplotypes {params.hidden_haplotypes}
        """


rule GeneratePGXReport:
    """ Generates markdown report per sample """
    params:
        haplotype_definitions = config["table_data"]["haplotype_definitions"],
        script_location = config["run_location"]
    input:
        found_variants  = "Results/Report/detected_variants/{sample}_{seqID}.csv",
        missed_variants = "Results/Report/coverage/{sample}_{seqID}_depth_at_missing_annotated.gdf",
        diploids        = "Results/Report/detected_variants/possible_diploids/{sample}_{seqID}.csv",
        depth_at_baits  = "Results/gdf/{sample}_{seqID}.gdf"
    output:
        html = "Results/Report/{sample}_{seqID}_pgx.html"
    singularity:
        config["singularities"]["rmarkdown"]
    shell:
        """
        wkdir=$(pwd)  # Needed since Rscript will set wd to location of file not session
        Rscript \
            -e ".libPaths('/lib/rlib'); library(rmdformats); rmarkdown::render('{params.script_location}/src/Report/generate_sample_report.Rmd', output_file='$wkdir/{output.html}', output_format=c('readthedown'))" \
            --args --title={wildcards.sample} --author=joel \
            --found_variants=$wkdir/{input.found_variants} \
            --missed_variants=$wkdir/{input.missed_variants}  \
            --haplotype_definitions=$wkdir/{params.haplotype_definitions} \
            --clinical_guidelines=$wkdir/{input.diploids} \
            --data_location=$wkdir/data \
            --depth_file=$wkdir/{input.depth_at_baits}
        """
