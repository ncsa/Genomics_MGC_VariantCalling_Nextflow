/*******************************************************************************************/
/*                                                                                         */
/*      This Nextflow script gathers per chr vcfs after joint calling a cohort             */
/*                                                                                         */
/*******************************************************************************************/

/*********         Nextflow option so bash stdout will be displayed           **************/
echo true


/*******************                   Import variables                   *****************/

InputVcfs = params.InputVcfs                  // Input GVCF files 
InputIdxs = params.InputIdxs                    // Input GVCF Index

GATKExe = file(params.GATKExe)                  // Path to GATK4 executable 
JavaExe = file(params.JavaExe)                  // Path to Java8 executable
JavaOptionsString = params.JavaOptionsString    // Required

BashPreamble = file(params.BashPreamble)        // script to source before every task
BashSharedFunctions = file(params.BashSharedFunctions) // script with shared functions
GatherVcfsScript = file(params.GatherVcfsScript)       // script of GATK code

DebugMode = params.DebugMode                           // Enable or Disable Debug Mode

DeliveryFolder_HaplotyperVC = params.DeliveryFolder_HaplotyperVC

/****************           Prepare needed input channels             *******************/ 

InputVcfsChannel = Channel.from(InputVcfs.tokenize(',')).flatMap{ files(it) }.collect()
InputIdxsChannel = Channel.fromPath(InputIdxs.tokenize(',')).collect()


/*************************            Start Merging Vcfs         ***********************/
process GatherVcfs {
   tag "All_samples_All_intervals"
 
   publishDir DeliveryFolder_HaplotyperVC, mode: 'copy' 

   input:
        file InputVcfs from InputVcfsChannel
        file InputIdxs from InputIdxsChannel

        file GATKExe
        file JavaExe
        val JavaOptionsString
        
        file BashPreamble
        file BashSharedFunctions
        file GatherVcfsScript 

	    val DebugMode

   output:
        file "GenomicGermlineVariants.vcf" into OutputVcf

   script:
       """
       source ${BashPreamble}
       /bin/bash ${GatherVcfsScript} -b ${InputVcfs.join(',')} -S ${GATKExe} -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} ${DebugMode}
       """
}
