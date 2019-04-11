# Haplotype Variant Calling with Sentieon on Nextflow
This repo is a variant calling pipeline that uses [sentieon](https://www.sentieon.com/) in [Nextflow](https://www.nextflow.io/) workflow management language, for use in detecting single nucleotide polymorphisms (SNP) and short insertion deletion variants. Nextflow-based implementation of [Cromwell-WDL based MayomicsVC workflow](https://github.com/ncsa/MayomicsVC).

## Acknowledgements
This work was a product of the Mayo Clinic and Illinois Strategic Alliance for Technology-Based Healthcare. Special thanks for the funding provided by the Mayo Clinic Center for Individualized Medicine and the Todd and Karen Wanek Program for Hypoplastic Left Heart Syndrome. We also thank the Interdisciplinary Health Sciences Institute, UIUC Institute for Genomic Biology and the National Center for Supercomputing Applications for their generous support and access to resources. We particularly acknowledge the support of Keith Stewart, M.B., Ch.B., Mayo Clinic/Illinois Grand Challenge Sponsor and Director of the Mayo Clinic Center for Individualized Medicine. Many thanks to the Sentieon team for consultation and advice on the Sentieon variant calling software.

## Intended pipeline architecture and function

Sentieon follows the [GATK best practices](https://software.broadinstitute.org/gatk/best-practices/), which takes in sequencing reads and uses alignment as a base. The aligned reads will then be further analyzed to call both indels and snps. This pipeline supports single-end read and paired-end read. Additionally, this pipeline also supports both single-lane samples and multi-lane samples.

The standard pipeline for this workflow is as follows:
  1. Trim sequences for each fastq files
  2. Align trimmed fastq files to the reference
  3. Remove duplicate reads
  4. Realign reads to reference
  5. Base quality score recalibration (BQSR)
  6. Haploype variant calling via Sentieon Haplotyper algorithm
  7. Variant quality score recalibration (VQSR)

**Figure 1:** Standard pipeline of Haplotype Variant Calling with Sentieon on Nextflow

(Image here)

This pipeline also supports multi-lane samples, allowing processing of fastq files from the same sample. This method is often use to increase overall data quality.

The standard multi-lane sample pipeline for this workflow is as follows:
  1. Trim sequences for each fastq files
  2. Align trimmed fastq files to the reference
  3. **Merge multi-lane samples**
  4. Remove duplicate reads
  5. Realign reads to reference
  6. Base quality score recalibration (BQSR)
  7. Haploype variant calling via Sentieon Haplotyper algorithm
  8. Variant quality score recalibration (VQSR)
  
**Figure 2:** Standard pipeline of multi-lane Haplotype Variant Calling with Sentieon on Nextflow

(Image here)

**IMPORTANT NOTE:** This workflow works chronologically. Which means to conduct one process, the previous processes must be done first. Although it is possible to do each step separately, the output of previous steps must still be present as an input for the next step. For a clear visual which process requires which process input, please refer to diagrams provided.




