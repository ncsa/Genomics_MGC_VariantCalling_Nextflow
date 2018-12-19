/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs BQSR using Sentieon                          */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -b        "Input deduped BAM"                         (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -k        "List of Known Sites"                       (Required)                  */
/*       -D        "Path to the DBSNP File"                    (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

echo true

Ref = file(params.Ref)
RefFai = file(params.RefFai)

InputAlignedSortedDedupedRealignedBam = file(params.InputAlignedSortedDedupedRealignedBam)
InputAlignedSortedDedupedRealignedBamBai = file(params.InputAlignedSortedDedupedRealignedBamBai)

SampleName = params.SampleName
BQSRKnownSites = params.BQSRKnownSites
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads

BQSRScript = params.BQSRScript
BQSREnvProfile = file(params.BQSREnvProfile)

DebugMode = params.DebugMode

process BQSR{
   input:
	file Ref
	file RefFai
	file InputAlignedSortedDedupedRealignedBam
	file InputAlignedSortedDedupedRealignedBamBai
	file BQSREnvProfile
	val BQSRScript
	val BQSRKnownSites

	val SampleName
	val SentieonThreads
	val Sentieon
	val DebugMode

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       """
       /bin/bash ${BQSRScript} -s ${SampleName} -b ${InputAlignedSortedDedupedRealignedBam} -G ${Ref} -k ${BQSRKnownSites} -S ${Sentieon} -t ${SentieonThreads} -e ${BQSREnvProfile}  ${DebugMode}
       """
}
