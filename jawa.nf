#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */

params.rnaseq = null
params.diffabun = null

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

process REPORT {

    tag "Report from nfcore/differentialabundance"


    publishDir 'results', mode: 'copy'

    input:
    path diffabun

    output:
    path 'report'

    script:
    def report_dir = "${diffabun}/report"
    """
    cp -r '${report_dir}' report
    """
}

process RESULT_TABLES {

    tag "Differential/processed abundance tables from nfcore/differentialabundance"

    publishDir 'results', mode: 'copy'

    input:
    path rnaseq
    path diffabun

    output:
    path "annotated*"

    script:
    """
    diffabun.py '${rnaseq}' '${diffabun}'
    """
}



workflow {

    rnaseq_ch = Channel.fromPath(params.rnaseq, checkIfExists: true)
    COUNT_FILE(rnaseq_ch)

    diffabun_ch = Channel.fromPath(params.diffabun, checkIfExists: true)
    RESULT_TABLES(rnaseq_ch, diffabun_ch)

    report_ch = Channel.fromPath(params.diffabun, checkIfExists: true)
    REPORT(report_ch)
}
