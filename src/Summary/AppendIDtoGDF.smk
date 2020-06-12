
rule AppendIDtoGDF:
    """ Add variant id to appropriate location in gdf """
    params:
        target_bed = config["table_data"]["target_rsid"]
    input:
        gdf = "Results/Report/coverage/{sample}_{seqID}_depth_at_missing.gdf"
    output:
        gdf = "Results/Report/coverage/{sample}_{seqID}_depth_at_missing_annotated.gdf"
    singularity:
        config["singularities"]["get_target"]
    shell:
         """
         python3 src/Summary/append_rsid_to_gdf.py \
            --input_gdf={input.gdf} \
            --target_bed={params.target_bed} \
            --output_file={output.gdf}
         """