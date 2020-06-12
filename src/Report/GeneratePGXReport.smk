## NOTE: setting '.libPaths('/lib/rlib')' specific to singularity used

rule GetClinicalGuidelines:
    params:
        haplotype_definitions = config["table_data"]["haplotype_definitions"],
        clinical_guidelines   = config["clinical_data"]["clinical_guidelines"],
        haplotype_activity    = config["clinical_data"]["haplotype_activity"],
        hidden_haplotypes     =config["table_data"]["hidden_haplotypes"]
    input:
        found_variants  = "Results/Pharmacogenomics/Report/detected_variants/{sample}_{seqID}.csv",
    output:
        csv = "Results/Pharmacogenomics/Report/detected_variants/possible_diploids/{sample}_{seqID}.csv"
    singularity:
        config["singularities"]["get_target"]
    shell:
        """
        python3 src/Summary/get_possible_diplotypes.py \
            --variant_csv {input.found_variants} \
            --haplotype_definitions {params.haplotype_definitions} \
            --clinical_guidelines {params.clinical_guidelines} \
            --haplotype_activity {params.haplotype_activity} \
            --output {output.csv} \
            --hidden_haplotypes {params.hidden_haplotypes}
        """


# TODO: Add graphics for coverage and clinical guidelines
rule GeneratePGXReport:
    params:
        haplotype_definitions = config["table_data"]["haplotype_definitions"]
    input:
        found_variants  = "Results/Pharmacogenomics/Report/detected_variants/{sample}_{seqID}.csv",
        missed_variants = "Results/Pharmacogenomics/Report/coverage/{sample}_{seqID}_depth_at_missing_annotated.gdf",
        diploids        = "Results/Pharmacogenomics/Report/detected_variants/possible_diploids/{sample}_{seqID}.csv",
        depth_at_baits  = "Results/Pharmacogenomics/gdf/{sample}_{seqID}.gdf"
    output:
        html = "Results/Pharmacogenomics/Report/{sample}_{seqID}_pgx.html"
    singularity:
        config["singularities"]["rmarkdown"]
    shell:
        """
        wkdir=$(pwd)  # Needed since Rscript will set wd to location of file not session
        Rscript \
            -e ".libPaths('/lib/rlib'); library(rmdformats); rmarkdown::render('src/Report/generate_sample_report.Rmd', output_file='$wkdir/{output.html}', output_format=c('readthedown'))" \
            --args --title={wildcards.sample} --author=joel \
            --found_variants=$wkdir/{input.found_variants} \
            --missed_variants=$wkdir/{input.missed_variants}  \
            --haplotype_definitions=$wkdir/{params.haplotype_definitions} \
            --clinical_guidelines=$wkdir/{input.diploids} \
            --data_location=$wkdir/data \
            --depth_file=$wkdir/{input.depth_at_baits}
        """
