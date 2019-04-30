/*******************************************************************************************/
/*                                                                                         */
/*      This Nextflow script merges input gvcfs before joint calling a cohort              */
/*                                                                                         */
/*******************************************************************************************/

/*********         Nextflow option so bash stdout will be displayed           **************/
echo true


/*******************                   Import variables                   *****************/
SampleName = params.SampleName                  // Name of the Sample

InputGvcfs = params.InputGvcfs                  // Input GVCF files 
InputIdxs = params.InputIdxs                    // Input GVCF Index

GATKExe = file(params.GATKExe)                  // Path to GATK4 executable 
JavaExe = file(params.JavaExe)                  // Path to Java8 executable
JavaOptionsString = params.JavaOptionsString    // Required

BashPreamble = file(params.BashPreamble)        // script to source before every task
BashSharedFunctions = file(params.BashSharedFunctions) // script with shared functions
MergeGvcfsScript = file(params.MergeGvcfsScript)       // script of GATK code

DebugMode = params.DebugMode                           // Enable or Disable Debug Mode

DeliveryFolder_HaplotyperVC = params.DeliveryFolder_HaplotyperVC

/****************           Prepare needed input channels             *******************/ 

InputGvcfsChannel = Channel.from(InputGvcfs.tokenize(',')).flatMap{ files(it) }.collect()
InputIdxsChannel = Channel.fromPath(InputIdxs.tokenize(',')).collect()


/*************************            Start haplotyper            ***********************/
process Mergegvcfs {
 
   publishDir DeliveryFolder_HaplotyperVC, mode: 'copy' 

   input:
    	val SampleName

        file InputGvcfs from InputGvcfsChannel
        file InputIdxs from InputIdxsChannel

        file GATKExe
        file JavaExe
        val JavaOptionsString
        
        file BashPreamble
        file BashSharedFunctions
        file MergeGvcfsScript 

	    val DebugMode

   output:
        file "${SampleName}.g.vcf" into OutputVcf
        file "${SampleName}.g.vcf.idx" into OutputVcfIdx

   script:
       """
       source ${BashPreamble}
       /bin/bash ${MergeGvcfsScript} -s ${SampleName} -b ${InputGvcfs.join(',')} -S ${GATKExe} -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} ${DebugMode}
       """
}
