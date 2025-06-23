#!/usr/bin/env python

import sys
from pathlib import Path

import pandas as pd

rnaseq_dir: Path = Path(sys.argv[1])
count_file: Path = (
    rnaseq_dir / "star_salmon/salmon.merged.gene_counts_length_scaled.tsv"
)

# this try-except block might be redundant as Nextflow  would be checking for the existence of files/folders
try:
    count_df: pd.DataFrame = pd.read_csv(
        filepath_or_buffer=count_file,
        sep="\t",
        index_col=None,
    )
    count_df: pd.DataFrame = count_df[["gene_id", "gene_name"]]

except FileNotFoundError:
    print(
        f"File {count_file} not found, make sure that you provide the correct path for the nfcore/rnaseq output folder. Exiting!",
    )
    sys.exit(1)


def annotate_tables(table_dir: Path) -> None:
    for file in table_dir.glob(pattern="*.tsv"):
        original_filename: str = file.name
        annotated_filename: str = f"annotated_{original_filename}"
        annotated_file: Path = Path(annotated_filename)

        diff_df: pd.DataFrame = pd.read_csv(
            filepath_or_buffer=file,
            sep="\t",
            index_col=None,
        )

        annotated_diff_df: pd.DataFrame = count_df.merge(
            right=diff_df,
            how="right",
            left_on="gene_id",
            right_on="gene_id",
        )

        annotated_diff_df.to_csv(
            path_or_buf=annotated_file,
            sep="\t",
            index=False,
        )


diffabun_dir: Path = Path(sys.argv[2])

diff_tables_dir: Path = diffabun_dir / "tables/differential"
annotate_tables(table_dir=diff_tables_dir)

proc_abun_tables_dir: Path = diffabun_dir / "tables/processed_abundance"
annotate_tables(table_dir=proc_abun_tables_dir)
