# Haplotype Variant Calling with Sentieon on Nextflow
This repo is a variant calling pipeline that uses [sentieon](https://www.sentieon.com/) in [Nextflow](https://www.nextflow.io/) workflow management language, for use in detecting single nucleotide polymorphisms (SNP) and short insertion deletion variants. Nextflow-based implementation of [Cromwell-WDL based MayomicsVC workflow](https://github.com/ncsa/MayomicsVC).

## Acknowledgements
This work was a product of the Mayo Clinic and Illinois Strategic Alliance for Technology-Based Healthcare. Special thanks for the funding provided by the Mayo Clinic Center for Individualized Medicine and the Todd and Karen Wanek Program for Hypoplastic Left Heart Syndrome. We also thank the Interdisciplinary Health Sciences Institute, UIUC Institute for Genomic Biology and the National Center for Supercomputing Applications for their generous support and access to resources. We particularly acknowledge the support of Keith Stewart, M.B., Ch.B., Mayo Clinic/Illinois Grand Challenge Sponsor and Director of the Mayo Clinic Center for Individualized Medicine. Many thanks to the Sentieon team for consultation and advice on the Sentieon variant calling software.

## Intended pipeline architecture and function

Sentieon follows the [GATK best practices](https://software.broadinstitute.org/gatk/best-practices/), which takes in sequencing reads and uses alignment as a base. The aligned reads will then be further analyzed to call both indels and snps. In this workflow, this pipeline supports both single-lane samples and multi-lane samples.

