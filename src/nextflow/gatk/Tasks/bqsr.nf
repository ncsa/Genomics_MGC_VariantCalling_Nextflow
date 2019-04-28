/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs BQSR using Sentieon                          */
/*                                                                                         */
/*                              Script Options                                             */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -b        "Input deduped BAM"                         (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -k        "List of Known Sites"                       (Required)                  */
/*       -O        "Path to Output Directory"                  (Required)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import Variables */
BQSRScript = params.BQSRScript
SampleName = params.SampleName
Ref = params.Ref
//RefFai = file(params.RefFai)
BQSRKnownSites = params.BQSRKnownSites
BQSROutputDirectory = params.BQSROutputDirectory
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads
BQSREnvProfile = file(params.BQSREnvProfile)
DebugMode = params.DebugMode

/** Retrieve realigned bams from realignment output directory */
RealignmentOutputDirectory = params.RealignmentOutputDirectory
InputAlignedSortedDedupedRealignedBam = file(RealignmentOutputDirectory + "/" + SampleName + ".aligned.sorted.deduped.realigned.bam")
InputAlignedSortedDedupedRealignedBamBai = file(RealignmentOutputDirectory + "/" + SampleName + ".aligned.sorted.deduped.realigned.bam.bai")


/** Start BQSR */
process BQSR{

   publishDir BQSROutputDirectory, mode: 'move'

   input:
	val Ref
//	file RefFai
	file InputAlignedSortedDedupedRealignedBam
	file InputAlignedSortedDedupedRealignedBamBai
	file BQSREnvProfile
	val BQSRScript
	val BQSRKnownSites
	val BQSROutputDirectory

	val SampleName
	val SentieonThreads
	val Sentieon
	val DebugMode

   output:
	file "${SampleName}.bqsr.TBD.log"
	file "${SampleName}.bqsr_sentieon.log"
	file "${SampleName}.recal.csv"
	file "${SampleName}.recal_data.table.post"
	file "${SampleName}.recal_plots.pdf"
   script:
       """
       /bin/bash ${BQSRScript} -s ${SampleName} -b ${InputAlignedSortedDedupedRealignedBam} -G ${Ref} -k ${BQSRKnownSites} -O ${BQSROutputDirectory} -S ${Sentieon} -t ${SentieonThreads} -e ${BQSREnvProfile} ${DebugMode}
       """
}
