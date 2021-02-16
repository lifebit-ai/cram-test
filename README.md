# sra-dbgap-datafetch

This is a minimal Nextflow pipleine with diffrent methods of accessing data from SRA-dbGaP.

# Usage

## With NGC key file

```bash
nextflow main.nf --accession_file list.txt --key_file key.ngc
```

Check how to get ngc key file - https://www.ncbi.nlm.nih.gov/sra/docs/sra-dbgap-download/

## With JWT cart file


```bash
nextflow main.nf --accession_file list.txt --cart_file cart.jwt
```

Check how to get cart jwt file - https://www.ncbi.nlm.nih.gov/sra/docs/sra-dbGAP-cloud-download/

# Other resources
* https://www.ncbi.nlm.nih.gov/sra/docs/SRA-Google-Cloud/
