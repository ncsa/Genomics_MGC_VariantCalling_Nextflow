/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs realignment using Sentieon                   */
/*                                                                                         */
/*                              Script Options                                             */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -b        "Input deduped BAM"                         (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -k        "List of Known Sites"                       (Required)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -t        "Number of Threads"                         (Optional)                  */
/* 	 -O 	   "Path to Output Directory"		       (Required)		   */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import variables */
RealignmentScript = params.RealignmentScript
SampleName = params.SampleName
Ref = params.Ref
//RefFai = file(params.RefFai)
RealignmentKnownSites = params.RealignmentKnownSites
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads
RealignEnvProfile = file(params.RealignEnvProfile)
RealignmentOutputDirectory = params.RealignmentOutputDirectory
DebugMode = params.DebugMode


/** Retrieve deduped bams from dedup output directory */
DedupOutputDirectory = params.DedupOutputDirectory
InputAlignedSortedDedupedBam = file(DedupOutputDirectory + "/" + SampleName + ".aligned.sorted.deduped.bam")
InputAlignedSortedDedupedBamBai = file(DedupOutputDirectory + "/" + SampleName + ".aligned.sorted.deduped.bam.bai")


/** Start realignment */
process Realignment{

   publishDir RealignmentOutputDirectory, mode: 'move'

   input:
	val Ref
	//file RefFai
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

   output:
	file "${SampleName}.realign_sentieon.log"
	file "${SampleName}.realignment.TBD.log"

   script:
       """
       /bin/bash ${RealignmentScript} -s ${SampleName} -b ${InputAlignedSortedDedupedBam} -G ${Ref} -k ${RealignmentKnownSites} -S ${Sentieon} -t ${SentieonThreads} -e ${RealignEnvProfile} -O ${RealignmentOutputDirectory} ${DebugMode}
       """
}
