
rule AppendIDtoGDF:
    """ Add variant id to appropriate location in gdf """
    params:
        target_bed = load_local(config["table_data"]["target_rsid"]),
        script_location   = config["run_location"]
    input:
        gdf = "work/{seqID}/Results/Report/coverage/{sample}_{seqID}_depth_at_missing.gdf"
    output:
        gdf = "work/{seqID}/Results/Report/coverage/{sample}_{seqID}_depth_at_missing_annotated.gdf"
    log:
        "logs/PGX/AppendIDtoGDF/{sample}_{seqID}.log"
    singularity:
        config["singularities"]["get_target"]
    shell:
         """
         python3 {params.script_location}/src/Summary/append_rsid_to_gdf.py \
            --input_gdf={input.gdf} \
            --target_bed={params.target_bed} \
            --output_file={output.gdf} &> {log}
         """