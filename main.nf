#!/usr/bin/env nextflow

if (param.key_file) {

  Channel
    .fromPath(params.key_file)
    .set { ch_key_file }

  process download_cram_ngc {
      container 'lifebitai/download_reads:latest'
      echo true

      input:
      file(key_file) from ch_key_file

      script:
      """
      prefetch --type $params.type --ngc $key_file --location $params.loc $params.accession
      """
  }

}

if (param.cart_file) {

  Channel
  .fromPath(params.cart_file)
  .set { ch_cart_file }

  process download_cram_jwt {
    container 'lifebitai/download_reads:latest'
    echo true

    input:
    file(cart_file) from ch_cart_file

    script:
    if (!$params.accession) $params.accession = ""
    """
    vdb-config --accept-gcp-charges yes --report-cloud-identity yes
    prefetch --perm $cart_file $params.accession
    """
  }

}

if (param.accession) {
  process test_sra {
      container 'lifebitai/download_reads:latest'
      echo true

      script:
      """
      test-sra $params.accession
      """
  }
}