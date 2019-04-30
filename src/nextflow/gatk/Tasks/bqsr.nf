/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs BQSR using GATK tools                        */
/*                                                                                         */
/*******************************************************************************************/

/***************       Nextflow option so bash stdout will be displayed       *** **********/
echo true

/***************************              Import Variables               *******************/
SampleName = params.SampleName                      // Name of the Sample

InputBams = file(params.InputBams)                  // Input Sorted Deduped Bam     ********/
InputBais = file(params.InputBais)                  // Input Sorted Deduped Bam Index ******/

Ref = file(params.Ref)                              // Reference Genome
RefFai = file(params.RefFai)                        // Reference files- implicit inputs
RefDict = file(params.RefDict)                      // to the GATK tool 

BqsrKnownSites = params.BqsrKnownSites              // List of known sites, including dbSNP*/
GenomicInterval = params.GenomicInterval            // Array of chromosome names or intervals
GATKExe = file(params.GATKExe)                      // Path to GATK4 executable
ApplyBQSRExtraOptionsString = params.ApplyBQSRExtraOptionsString //ApplyBQSR extra options
JavaExe = file(params.JavaExe)                      // Path to Java8 executable
JavaOptionsString = params.JavaOptionsString        // java vm options- Required

BashPreamble = file(params.BashPreamble)               // script to run before every task
BashSharedFunctions = file(params.BashSharedFunctions) //script of shared functions
BqsrScript = file(params.BqsrScript)                   // script of the bqsr job

DebugMode = params.DebugMode                           // Enable or Disable Debug Mode

DeliveryFolder_Alignment = params.DeliveryFolder_Alignment

/******************** Retrieve realigned bams from realignment output directory ************************/

BqsrKnownSitesChannel = Channel.from(BqsrKnownSites.tokenize(',')).flatMap{ files(it) }.collect()
BqsrKnownSitesIdxChannel = Channel.from(BqsrKnownSites.tokenize(',')).flatMap{ files(it+'.idx') }.collect()

/*************************************               Start BQSR              ****************************/
process BQSR{

   publishDir DeliveryFolder_Alignment, mode: 'copy'

   input:
        val SampleName
    	file InputBams
	    file InputBais

    	file Ref
      	file RefFai
        file RefDict

    	file BqsrKnownSites from BqsrKnownSitesChannel
    	file BqsrKnownSitesIdx from BqsrKnownSitesIdxChannel

        val GenomicInterval
        file GATKExe
        val ApplyBQSRExtraOptionsString
        file JavaExe
        val JavaOptionsString
        
        file BashPreamble
        file BashSharedFunctions
        file BqsrScript

   output:
        file "${SampleName}.${GenomicInterval}.bam"
        file "${SampleName}.${GenomicInterval}.bai"

   script:
       """
        source ${BashPreamble}
       /bin/bash ${BqsrScript} -s ${SampleName} -b ${InputBams} -G ${Ref} -k ${BqsrKnownSites.join(',')} -I ${GenomicInterval} -S ${GATKExe} -o \"\'${ApplyBQSRExtraOptionsString}\'\" -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} ${DebugMode}
       """
}
