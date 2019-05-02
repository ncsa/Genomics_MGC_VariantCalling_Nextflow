/*******************************************************************************************/
/*                                                                                         */
/*            This Nextflow script jointly calls from a cohort of samples                  */
/*                                                                                         */
/*******************************************************************************************/

/*********         Nextflow option so bash stdout will be displayed           **************/
echo true


/*******************                   Import variables                   *****************/

InputGvcfs = params.InputGvcfs                  // Input GVCF files 
InputIdxs = params.InputIdxs                    // Input GVCF Index


Ref = file(params.Ref)                          // Reference genome
RefFai = file(params.RefFai)                    // Reference files- implicit
RefDict = file(params.RefDict)                  // to the GATK tool
DBSNP = file(params.DBSNP)                  // DBSNP file
DBSNPIdx = file(params.DBSNPIdx)            // Index file for DBSNP file
GenomicInterval = params.GenomicInterval            // Array of chromosome names or intervals

GATKExe = file(params.GATKExe)                  // Path to GATK4 executable 
GenotypeGVCFsExtraOptionsString = params.GenotypeGVCFsExtraOptionsString //GenotypeGVCFs extra options
JavaExe = file(params.JavaExe)                  // Path to Java8 executable
JavaOptionsString = params.JavaOptionsString    // Required

BashPreamble = file(params.BashPreamble)        // script to source before every task
BashSharedFunctions = file(params.BashSharedFunctions) // script with shared functions
JointGenotypingScript = file(params.JointGenotypingScript)       // script of GATK code

DebugMode = params.DebugMode                           // Enable or Disable Debug Mode


/****************           Prepare needed input channels             *******************/ 

InputGvcfsChannel = Channel.from(InputGvcfs.tokenize(',')).flatMap{ files(it) }.collect()
InputIdxsChannel = Channel.fromPath(InputIdxs.tokenize(',')).collect()


/*************************            Start Merging Gvcfs         ***********************/
process JointGenotyping {
 

   input:
        file InputGvcfs from InputGvcfsChannel
        file InputIdxs from InputIdxsChannel

        file Ref
        file RefFai
        file RefDict
        file DBSNP
//      file DBSNPIdx

        val GenomicInterval
        
        file GATKExe
        val GenotypeGVCFsExtraOptionsString 
        file JavaExe
        val JavaOptionsString
        
        file BashPreamble
        file BashSharedFunctions
        file JointGenotypingScript

	    val DebugMode

   output:
        file "${GenomicInterval}.vcf" into OutputVcf
        file "${GenomicInterval}.vcf.idx" into OutputVcfIdx

   script:
       """
       source ${BashPreamble}
       /bin/bash ${JointGenotypingScript} -b ${InputGvcfs.join(',')} -G ${Ref} -D ${DBSNP} -I ${GenomicInterval} -S ${GATKExe} -o \"\'${GenotypeGVCFsExtraOptionsString}\'\" -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} ${DebugMode}
       """
}
