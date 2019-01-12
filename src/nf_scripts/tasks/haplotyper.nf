/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs Haplotyping using Sentieon                   */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Required)                  */
/*       -b        "Input Aligned,Sorted,Deduped,Realigned BAM"(Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -r        "Recal Data Table"                          (Required)                  */
/*       -o        "Haplotyper Extra Options"                  (Required)                  */
/*       -D        "Path to the DBSNP File"                    (Required)                  */
/* 	 -O	   "Path to the Output Folder"		       (Required)		   */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

echo true

Ref = file(params.Ref)
RefFai = file(params.RefFai)

InputAlignedSortedDedupedRealignedBam = file(params.InputAlignedSortedDedupedRealignedBam)
InputAlignedSortedDedupedRealignedBamBai = file(params.InputAlignedSortedDedupedRealignedBamBai)
RecalTable = file(params.RecalTable)

DBSNP = file(params.DBSNP)
DBSNPidx = file(params.DBSNPidx)

SampleName = params.SampleName
HaplotyperExtraOptions = params.HaplotyperExtraOptions
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads

HaplotyperScript = params.HaplotyperScript
HaplotyperEnvProfile = file(params.HaplotyperEnvProfile)
HaplotyperOutputDirectory = params.HaplotyperOutputDirectory

DebugMode = params.DebugMode

process Haplotyping{
   input:
	file Ref
	file RefFai
	file InputAlignedSortedDedupedRealignedBam
	file InputAlignedSortedDedupedRealignedBamBai
	file DBSNP
	file DBSNPidx
	file RecalTable
	
	file HaplotyperEnvProfile
	val HaplotyperScript
	val HaplotyperOutputDirectory	

	val SampleName
	val SentieonThreads
	val HaplotyperExtraOptions
	String HaplotyperFinalExtraOptions = "\"" + HaplotyperExtraOptions + "\""
	val Sentieon
	val DebugMode

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       """
       /bin/bash ${HaplotyperScript} -s ${SampleName} -b ${InputAlignedSortedDedupedRealignedBam} -G ${Ref} -D ${DBSNP} -r ${RecalTable} -S ${Sentieon} -t ${SentieonThreads} -O ${HaplotyperOutputDirectory} -o ${HaplotyperFinalExtraOptions} -e ${HaplotyperEnvProfile}  ${DebugMode}
       """
}
