/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs Haplotyping using Sentieon                   */
/*                                                                                         */
/*******************************************************************************************/

/*********         Nextflow option so bash stdout will be displayed           **************/
echo true


/*******************                   Import variables                   *****************/
SampleName = params.SampleName              // Name of the Sample
InputBams = file(params.InputBams)          // Input Sorted Deduped Bam
InputBais = file(params.InputBais)          // Input Sorted Deduped Bam Index

Ref = file(params.Ref)                      // Reference Genome
RefFai = file(params.RefFai)                // Reference Genome index
RefDict = file(params.RefDict)              // Reference Genome dictionary

DBSNP = file(params.DBSNP)                  // DBSNP file
DBSNPIdx = file(params.DBSNPIdx)            // Index file for DBSNP file
GenomicInterval = params.GenomicInterval   // Array of chromosome names/genomic intervals

GATKExe = file(params.GATKExe)              // Path to GATK4 executable 
HaplotyperThreads = params.HaplotyperThreads
HaplotyperExtraOptionsString = params.HaplotyperExtraOptionsString // Optional
JavaExe = file(params.JavaExe)              // Path to Java8 executable
JavaOptionsString = params.JavaOptionsString// Required

BashPreamble = file(params.BashPreamble)    // script to source before every task
BashSharedFunctions = file(params.BashSharedFunctions) // script with shared functions
HaplotyperScript = file(params.HaplotyperScript)       // script of GATK code

DebugMode = params.DebugMode

DeliveryFolder_HaplotyperVC = params.DeliveryFolder_HaplotyperVC

/****************           Prepare needed input channels             *******************/ 


/*************************            Start haplotyper            ***********************/
process Haplotyper{
 
   publishDir DeliveryFolder_HaplotyperVC, mode: 'copy' 

   input:
    	val SampleName

    	file InputBams
	    file InputBais
    	file Ref
	    file RefFai
        file RefDict

    	file DBSNP
	    file DBSNPIdx
	    val GenomicInterval
        
        file GATKExe
        val HaplotyperThreads
        val HaplotyperExtraOptionsString
        file JavaExe
        val JavaOptionsString
        
        file BashPreamble
        file BashSharedFunctions
        file HaplotyperScript

	    val DebugMode

   output:
        file "${SampleName}.${GenomicInterval}.g.vcf" into OutputVcf
        file "${SampleName}.${GenomicInterval}.g.vcf.idx" into OutputVcfIdx

   script:
       """
       source ${BashPreamble}
       /bin/bash ${HaplotyperScript} -s ${SampleName} -b ${InputBams} -G ${Ref} -D ${DBSNP} -I ${GenomicInterval} -S ${GATKExe} -t ${HaplotyperThreads} -o \"\'${HaplotyperExtraOptionsString}\'\" -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} ${DebugMode}
       """
}
