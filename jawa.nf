#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */

params.rnaseq = null

process COUNT_FILE {

    tag "Counts from nfcore/rnaseq"

    publishDir 'results', mode: 'copy'

    input:
    path rnaseq

    output:
    path 'salmon.merged.gene_counts_length_scaled.tsv'

    script:
    def count_file = "${rnaseq}/star_salmon/salmon.merged.gene_counts_length_scaled.tsv"
    """
    cp '${count_file}' salmon.merged.gene_counts_length_scaled.tsv
    """
}

workflow {

    rnaseq_ch = Channel.fromPath(params.rnaseq, checkIfExists: true)
    COUNT_FILE(rnaseq_ch)
}
