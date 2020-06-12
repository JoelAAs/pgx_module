from pysam import VariantFile
import argparse
import sys


def filter_variants(vcf, read_ratio, depth, output):
    vcf_in = VariantFile(vcf)
    new_header = vcf_in.header
    new_header.filters.add(f"AR{read_ratio}", None, None,
                           f"Ratio of ref/alt reads lower than {read_ratio}")
    new_header.filters.add(f"DP{depth}", None, None, f"DP is lower than {depth}x")
    vcf_out = VariantFile(output, "w", header=new_header)

    for record in vcf_in.fetch():
        ad = record.samples[0]["AD"]
        #  No multiallelic split

        if record.info["DP"] < depth:
            record.filter.add("DP100")

        elif len(ad) == 2:
            n_ref, n_alt = ad
            if n_alt / (n_ref + n_alt) < read_ratio:
                record.filter.add(f"AR{read_ratio}")
            else:
                record.filter.add("PASS")
        vcf_out.write(record)


def main():
    parser = argparse.ArgumentParser(
        description="Filter variants on depth and read ratio"
    )
    parser.add_argument("--input_vcf", type=str)
    parser.add_argument("--read_ratio", type=float)
    parser.add_argument("--depth", type=int)
    parser.add_argument("--output_file", type=str)

    args = parser.parse_args(sys.argv[1:])

    input_vcf = args.input_vcf
    read_ratio = args.read_ratio
    depth = args.depth
    output_file = args.output_file

    filter_variants(input_vcf, read_ratio, depth, output_file)


if __name__ == '__main__':
    main()
