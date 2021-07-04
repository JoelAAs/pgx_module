import pandas as pd
import argparse
import sys
import numpy as np
from itertools import product


class GetInteractions:
    def __init__(self, variants_file, guideline_file):
        self.variants_df = pd.read_csv(variants_file, sep="\t")
        self.interaction_guidelines_df = pd.read_csv(guideline_file, sep="\t")

    def get_possible_interactions(self):
        # TODO: refactor inefficient and ugly
        interacting_genes = set(self.interaction_guidelines_df[["gene1", "gene2"]].values.flat)
        self.variants_df = self.variants_df[[self.variants_df.gen.isin(interacting_genes)]]

        index_combinations = product(
            range(len(self.variants_df)),
            range(len(self.variants_df))
        )

        for i, j in index_combinations:
            prev_idx = np.zeros(len(self.interaction_guidelines_df), dtype=bool)
            if not i == j:
                gene1 = self.variants_df.iloc[[i]].gene
                gene2 = self.variants_df.iloc[[j]].gene

                activity1 = int(self.variants_df.iloc[[i]].Genotype_activity)
                activity2 = int(self.variants_df.iloc[[i]].Genotype_activity)

                idx = (self.interaction_guidelines_df.gene1 == gene1) & \
                      (self.interaction_guidelines_df.gene2 == gene2) & \
                      (self.interaction_guidelines_df.activity_1 == activity1) & \
                      (self.interaction_guidelines_df.activity_2 == activity2)

                if any(idx):
                    prev_idx += idx

        return self.interaction_guidelines_df[idx]

    def run_and_write(self, output):
        interactions = self.get_possible_interactions()
        interactions.to_csv(output, index=None, sep="\t")


def main():
    parser = argparse.ArgumentParser(
        description="Get guidelines based on interacting variants in different genes"
    )
    parser.add_argument("--diploids", type=str)
    parser.add_argument("--interaction_guidelines", type=str)
    parser.add_argument("--output", type=str, help="Location of output")
    args = parser.parse_args(sys.argv[1:])
    get_interactions = GetInteractions(args.diploids, args.interaction_guidelines)
    get_interactions.run_and_write(args.output)


if __name__ == '__main__':
    main()
