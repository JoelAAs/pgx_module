## NOTE: setting '.libPaths('/lib/rlib')' specific to singularity used

rule GetClinicalGuidelines:
    """ Given detected variants, get possible Haplotype combinations """
    params:
        haplotype_definitions = load_local(config["table_data"]["haplotype_definitions"]),
        clinical_guidelines   = load_local(config["clinical_data"]["clinical_guidelines"]),
        haplotype_activity    = load_local(config["clinical_data"]["haplotype_activity"]),
        hidden_haplotypes     = load_local(config["table_data"]["hidden_haplotypes"]),
        script_location       = config["run_location"]
    input:
        found_variants  = "work/{seqID}/Results/Report/detected_variants/{sample}_{seqID}.csv",
    output:
        csv = "work/{seqID}/Results/Report/detected_variants/possible_diploids/{sample}_{seqID}.csv"
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
        haplotype_definitions = load_local(config["table_data"]["haplotype_definitions"]),
        script_location = config["run_location"]
    input:
        found_variants  = "work/{seqID}/Results/Report/detected_variants/{sample}_{seqID}.csv",
        missed_variants = "work/{seqID}/Results/Report/coverage/{sample}_{seqID}_depth_at_missing_annotated.gdf",
        diploids        = "work/{seqID}/Results/Report/detected_variants/possible_diploids/{sample}_{seqID}.csv",
        depth_at_baits  = "work/{seqID}/Results/gdf/{sample}_{seqID}.gdf"
    output:
        html = "work/{seqID}/Results/Report/{sample}_{seqID}_pgx.html"
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
            --haplotype_definitions={params.haplotype_definitions} \
            --clinical_guidelines=$wkdir/{input.diploids} \
            --data_location={params.script_location}/data \
            --depth_file=$wkdir/{input.depth_at_baits}
        """
