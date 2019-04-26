# Haplotype Variant Calling with Sentieon on Nextflow
This repo is a variant calling pipeline that uses [sentieon](https://www.sentieon.com/) in [Nextflow](https://www.nextflow.io/) workflow management language, for use in detecting single nucleotide polymorphisms (SNP) and short insertion deletion variants. Nextflow-based implementation of Cromwell-WDL based [MayomicsVC workflow](https://github.com/ncsa/MayomicsVC).

## Acknowledgements
This work was a product of the Mayo Clinic and Illinois Strategic Alliance for Technology-Based Healthcare. Special thanks for the funding provided by the Mayo Clinic Center for Individualized Medicine and the Todd and Karen Wanek Program for Hypoplastic Left Heart Syndrome. We also thank the Interdisciplinary Health Sciences Institute, UIUC Institute for Genomic Biology and the National Center for Supercomputing Applications for their generous support and access to resources. We particularly acknowledge the support of Keith Stewart, M.B., Ch.B., Mayo Clinic/Illinois Grand Challenge Sponsor and Director of the Mayo Clinic Center for Individualized Medicine. Many thanks to the Sentieon team for consultation and advice on the Sentieon variant calling software.

**Table of Contents**
 - [Haplotype Variant Calling with Sentieon on Nextflow](#haplotype-variant-calling-with-sentieon-on-nextflow)
   - [Acknowledgements](#acknowledgements)
   - [Intended pipeline architecture and function](#intended-pipeline-architecture-and-function)
   - [Installation and Dependencies](#installation-and-dependencies)
      * [Dependencies](#dependencies)
      * [Workflow Installation](#workflow-installation)
   - [User Guide](#user-guide)
     * [Data Preparation](#data-preparation)
     * [VC_workflow config Parameters](#vc_workflow-config-parameters)
        - [Nextflow Parameters](#nextflow-parameters)
        - [General Parameters for Sentieon Workflow](#general-parameters-for-sentieon-workflow)
        - [Specific Parameters for Sentieon Workflow](#specific-parameters-for-sentieon-workflow)
            * [Trim sequences](#trim-sequences)
            * [Alignment](#alignment)
            * [Realignment](#realignment)
            * [BQSR](#bqsr)
            * [Haplotyper](#haplotyper)
            * [VQSR](#vqsr)
     * [Executing nextflow application](#executing-nextflow-application)
     * [Logging functionality](#logging-functionality)

     
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
  
  
**Figure 1:** Standard pipeline of Haplotype Variant Calling with Sentieon on Nextflow

<p align="center">
  <img src="/images/Diagram.png" width="100%">
</p>

**IMPORTANT NOTE:** This workflow works chronologically. Which means to conduct one process, the previous processes must be done first. Although it is possible to do each step separately, the output of previous steps must still be present as an input for the next step. For a clear visual which process requires which process input, please refer to diagrams provided.

## Installation and Dependencies

### Dependencies

- [Nextflow](https://www.nextflow.io/) 0.30.1.4844 or newer is recommeded.
- [Sentieon](https://www.sentieon.com/) (Propreitary software).
- [CutAdapt](https://cutadapt.readthedocs.io/en/stable/)

### Workflow Installation

Clone this repository

## User Guide

### Data Preparation
For a complete process, this workflow requires:
- Sample read files (usually fastq files)
- Reference fasta file, indexed
- Extra Variant Calling Foramat (VCF) files with known SNPs

### VC_workflow config Parameters

This workflow requires `/NextflowConfig/VC_workflow.config` to be properly filled, where the all information will be taken in from the user and processed by the workflow. In the file, only parameters within `params{}` scope should be filled.

**Note:** String parameters need quotation marks ("") in the beginning and end of the string.

#### Nextflow Parameters

**`NextflowExecutable`**

**STRING**

Path to nextflow executable

**`NextflowScriptsDir`**

**STRING**

Absolute path to the directory of process nextflow scripts, `/src/nextflow/Tasks`.

**`NextflowShellDir`**

**STRING**

Absolute path to the directory of process shell scripts used by nextflow, `/src/shell`

**`ConfigsDir`**

**STRING**

Absolute path to the directory of where this config file is, `/src/NextflowConfig`.

#### General Parameters for Sentieon Workflow

**`SampleName`**

**STRING**

The name of sample to use as prefix of output files.

**`PairedEnd`**

**STRING**

"true" or "false", parameter indicating the nature of the fastq reads. Whether it is paired reads or single reads.

**`DebugMode`**

**STRING**

"-d" or "", when set as "-d" the workflow will be more verbose.

**`Platform`**

**STRING**

The platform in which the reads were sequenced, will be used for labeling. Example: "Illumina".

**`Sentieon`**

**STRING**

Path to Sentieon **head directory**, not the executable.

**`SentieonThreads`**

**STRING**

Number of threads, surrounded by quotation marks. Example: "24" notice the quotation marks around the number

**`SharedFunctionScript`**

**STRING**

Path to shared function script within NextflowShellDir specified above. By default, this is filled by: `/src/shell/shared_functions.sh`. 

**`InputRead1`**

**STRING**

Path to left reads for paired-read samples , or path to reads in single-read samples. 
For multi-lane samples, please use a comma (,) for delimiter, without whitespace. Examples:

Single-lane sample:

`InputRead1 = "/path/to/read_1.fq"`

Multi-lane samples:

`InputRead1 = "/path/to/read_1_lane_1.fq","/path/to/read_1_lane_2.fq"`

**`InputRead2`**

**STRING**

Path to right reads for paired-read samples. Fill "", for single-read samples. For multi-lane samples, please use a comma (',') for delimiter, without whitespace, as InputRead1.

**NOTE**: The lanes are ordered by index, so it the input string should be consistent with the samples above.

Example:

`InputRead1 = "/path/to/read_1_lane_1.fq","/path/to/read_1_lane_2.fq"`

`InputRead2 = "/path/to/read_2_lane_1.fq","/path/to/read_2_lane_2.fq"`

The lanes **must** be consistent so they do not get mixed up.

#### Specific Parameters for Sentieon Workflow

**`(PROCESSNAME)Script`**

**STRING**

Absolute path to the shell script for the process. 

Example:

`TrimSeqScript = "/path/to/Genomics_MGC_VariantCalling_Nextflow/src/shell/trim_sequences.sh"`

**`(PROCESSNAME)OutputDirectory`**

**STRING**

Absolute path to the output directory the specific process

**`(PROCESSNAME)Profile`**

**STRING**

Absolute path to environment profile file. This script generally has one line, setting the SENTIEON_LICENSE variable to a some license server. This is the variable sentieon uses to get the details of the process, to monitor the use of sentieon software.

Example:

`RealignEnvProfile = "/path/to/env_file.txt"`

Within `RealignEnvProfile`:

`export SENTIEON=(address to license server)`


##### Trim sequences

**`TrimMultinode`**

**STRING**

Indicates if multiple nodes are used in the process for multilane samples. "true" or "false"

**`TrimExecutor`**

**STRING**

The type of executor that will be used. refer to nextflow executors [documentation](https://www.nextflow.io/docs/latest/executor.html)

**`TrimQueue`**

**STRING**

Queue name in the cluster, refer to nextflow executor [documentation](https://www.nextflow.io/docs/latest/executor.html)

**`TrimCpus`**

**STRING**

Number of cores per node for each process, refer to nextflow cpus [documentation](https://www.nextflow.io/docs/latest/process.html#cpus)

**`TrimWalltime`**

**STRING**

Walltime for individual process runs, refer to nextflow walltime [documentation](https://www.nextflow.io/docs/latest/process.html#process-time)

**`TrimMaxNodes`**

**INT**

Maximum number of nodes to be used in parallel, refer to nextflow maxForks [documentation]('https://www.nextflow.io/docs/latest/process.html?highlight=maxforks#maxforks')

**`Adapters`**

**STRING**

Path to adapter fasta files

**`CutAdapt`**

**STRING**

Path to bin directory of Python executable with installed [CutAdapt](https://cutadapt.readthedocs.io/en/stable/)

**`CutAdaptThreads`**

**STRING**

The number of threads for CutAdapt

##### Alignment

**`AlignmentMultinode`**

**STRING**

Indicates if multiple nodes are used in the process for multilane samples. "true" or "false"

**`AlignmentExecutor`**

**STRING**

The type of executor that will be used. refer to nextflow executors [documentation](https://www.nextflow.io/docs/latest/executor.html)

**`AlignmentQueue`**

**STRING**

Queue name in the cluster, refer to nextflow executor [documentation](https://www.nextflow.io/docs/latest/executor.html)

**`AlignmentCpus`**

**STRING**

Number of cores per node for each process, refer to nextflow cpus [documentation](https://www.nextflow.io/docs/latest/process.html#cpus)

**`AlignmentWalltime`**

**STRING**

Walltime for individual process runs, refer to nextflow walltime [documentation](https://www.nextflow.io/docs/latest/process.html#process-time)

**`AlignmentMaxNodes`**

**INT**

Maximum number of nodes to be used in parallel, refer to nextflow maxForks [documentation]('https://www.nextflow.io/docs/latest/process.html?highlight=maxforks#maxforks')

**`Ref`**

**STRING**

Path to reference genome fasta file

**`Ref(Amb/Ann/Bwt/Pac/Sa)`**

**STRING**

Path to reference index files generated by bwa aligners

**`ChunkSize`**

**STRING**

Refer to [sentieon documentation](https://support.sentieon.com/manual/DNAseq_usage/dnaseq/)

**`Library`**

**STRING**

Library variable for labeling purposes

**`SequencingCenter`**

**STRING**

Sequencing center variable for labeling purposes

**`BWAExtraOption`**

**STRING**

Determines whether to make split reads as secondary, consult [sentieon documentation](https://support.sentieon.com/manual/usages/general/#bwa-binary)


##### Realignment

**`RealignmentKnownSites`**

**STRING**

Path to vcf files with confirmed SNP sites (high confidence sites)

##### BQSR

**`BQSRKnownSites`**

**STRING**

Path to vcf files with confirmed SNP sites (high confidence sites)

##### Haplotyper

**`DBSNP`**

**STRING**

Path to dbSNP file

**`DBSNPidk`**

**STRING**

Path to dbSNP index file

**`HaplotyperExtraOptions`**

**STRING**

Extra options for haplotyper, refer to [sentieon haplotyper documentation](https://support.sentieon.com/manual/usages/general/?highlight=haplotyper#haplotyper-algorithm)

**NOTE:** Must be enclosed in a single-quotation within the double quotes "'(INPUT)'"

##### VQSR

**`VqsrSnpResourceString`**

**STRING**

Resources for SNP VQSR, refer to [sentieon VQSR documentation(https://support.sentieon.com/manual/usages/general/?highlight=vqsr#varcal-algorithm)

**NOTE:** Must be enclosed in a single-quotation within the double quotes "'(INPUT)'"

**`VqsrIndelResourceString`**

**STRING**

Resources for Indel VQSR, refer to [sentieon VQSR documentation(https://support.sentieon.com/manual/usages/general/?highlight=vqsr#varcal-algorithm)

**NOTE:** Must be enclosed in a single-quotation within the double quotes "'(INPUT)'"

**`AnnotateText`**

**STRING**

Refer to --annotation option [sentieon VQSR documentation(https://support.sentieon.com/manual/usages/general/?highlight=vqsr#varcal-algorithm)

**NOTE:** Must be enclosed in a single-quotation within the double quotes "'(INPUT)'"


### Executing Nextflow Application

The suggested practice to execute nextflow is to place the folder containing binary executable for nextflow in the PATH environment or to use full path to the nextflow executable file.

Example:
```
cd (head_output_directory)
nextflow run /src/nextflow/Workflow/VC_workflow.nf -c /NextflowConfig/VC_workflow
```

### Logging Functionality

Nextflow creates `work` folder where the command `nextflow (script.nf)` is run. Within the `work` folder, there will be nested folders, containing the log of individual processes. In the stdout of running script, there will be lines that is similar to this:

`[73/a3f6d2] Submitted process > test`

`test` is the process name. `[73/a3f6d2]` indicates the folder name within work folder when the user can locate the log for the specific process. More accurately, within `/work/73/` there might be several folders, and `a3f6d2` is the first 6 characters of the nested folder within `/work/73/`. Inside the folder specific to the process, such as `/work/73/a3f6d2...`, there are several log files that can be used for debugging or troubleshooting.








