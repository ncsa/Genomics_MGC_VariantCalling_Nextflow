/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs realignment using Sentieon                   */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -b        "Input deduped BAM"                         (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -k        "List of Known Sites"                       (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/* 	 -D 	   "Path to Output Directory"		       (Required)		   */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

echo true

Ref = file(params.Ref)
RefFai = file(params.RefFai)

InputAlignedSortedDedupedBam = file(params.InputAlignedSortedDedupedBam)
InputAlignedSortedDedupedBamBai = file(params.InputAlignedSortedDedupedBamBai)

SampleName = params.SampleName
RealignmentKnownSites = params.RealignmentKnownSites
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads

RealignmentScript = params.RealignmentScript
RealignEnvProfile = file(params.RealignEnvProfile)
RealignmentOutputDirectory = params.RealignmentOutputDirectory

DebugMode = params.DebugMode

process Realignment{
   input:
	file Ref
	file RefFai
	file InputAlignedSortedDedupedBam
	file InputAlignedSortedDedupedBamBai       
	file RealignEnvProfile
	val RealignmentScript
	val RealignmentOutputDirectory

	val SampleName
	val RealignmentKnownSites
	val SentieonThreads
	
	val Sentieon
	val DebugMode

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       """
       /bin/bash ${RealignmentScript} -s ${SampleName} -b ${InputAlignedSortedDedupedBam} -G ${Ref} -k ${RealignmentKnownSites} -S ${Sentieon} -t ${SentieonThreads} -e ${RealignEnvProfile} -D ${RealignmentOutputDirectory}  ${DebugMode}
       """
}
