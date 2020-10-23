#!/usr/bin/env nextflow

Channel
  .fromPath(params.key_file)
  .set { ch_key_file }

process download_cram {
    container 'lifebitai/download_reads:latest'
    echo true

    input:
    file(key_file) from ch_key_file

    script:
    """
    prefetch --type $params.type --ngc $key_file --location $params.loc $params.accession
    """
}

process test_sra {
    container 'lifebitai/download_reads:latest'
    echo true

    script:
    """
    test-sra $params.accession
    """
}