#!/usr/bin/env nextflow

if (params.accession_file){
  Channel
    .fromPath(params.accession_file)
    .splitCsv()
    .map { sample -> sample[0].trim() }
    .into { ch_accession_id; ch_accession_id_2; ch_accession_id_3 }
}

if (params.accession){
  Channel
    .value(params.accession)
    .into { ch_accession_id; ch_accession_id_2; ch_accession_id_3 }
}

// view all accessions from channel
// ch_accession_id.view()

if (params.key_file) {

  Channel
    .fromPath(params.key_file)
    .into { ch_key_file; ch_key_file_2 }

  process download_with_ngc {
      publishDir "${params.outdir}/download_with_ngc", mode: 'copy'
      tag "${accession_id}"
      echo true

      input:
      each file(key_file) from ch_key_file
      val(accession_id) from ch_accession_id

      output:
      file("*")

      script:
      """
      prefetch --type $params.type --ngc $key_file --location $params.loc $accession_id \
        --progress
      """
  }

  process splicing_pipelines_way {
      publishDir "${params.outdir}/splicing_pipelines_way", mode: 'copy'
      tag "${accession_id}"
      echo true

      input:
      each file(key_file) from ch_key_file_2
      val(accession_id) from ch_accession_id_3

      output:
      file("*")

      script:
      def ngc_cmd_with_key_file = params.key_file ? "--ngc ${key_file}" : ''
      """
      prefetch $ngc_cmd_with_key_file $accession_id --progress -o $accession_id
      fasterq-dump $ngc_cmd_with_key_file $accession_id --threads ${task.cpus} --split-3
      pigz *.fastq
      """
  }

  

}

if (params.cart_file) {

  Channel
  .fromPath(params.cart_file)
  .set { ch_cart_file }

  process download_with_jwt {
    publishDir "${params.outdir}/download_with_jwt", mode: 'copy'
    tag "${accession_id}"
    echo true

    input:
    each file(cart_file) from ch_cart_file
    val(accession_id) from ch_accession_id

    output:
    file("*")

    script:
    if (!params.accession) accession_id = ""
    """
    vdb-config --accept-gcp-charges yes --report-cloud-identity yes
    prefetch --perm $cart_file $accession_id --progress
    """
  }

}

if (ch_accession_id) {
  process test_sra {
      publishDir "${params.outdir}/sra_test", mode: 'copy'
      tag "${accession_id}"

      input:
      val(accession_id) from ch_accession_id_2

      output:
      file("*.xml")

      script:
      """
      test-sra $accession_id > ${accession_id}.xml
      """
  }
}
