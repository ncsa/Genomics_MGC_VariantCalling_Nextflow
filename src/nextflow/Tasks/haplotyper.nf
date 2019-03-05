/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs Haplotyping using Sentieon                   */
/*                                                                                         */
/*                              Script Options                                             */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -b        "Input Aligned,Sorted,Deduped,Realigned BAM"(Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -D        "Path to the DBSNP File"                    (Required)                  */
/*       -r        "Recal Data Table"                          (Required)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -t        "Number of Threads"                         (Required)                  */
/* 	 -O	   "Path to the Output Folder"		       (Required)		   */
/*       -o        "Haplotyper Extra Options"                  (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import variables */
HaplotyperScript = params.HaplotyperScript
SampleName = params.SampleName
Ref = params.Ref
//RefFai = file(params.RefFai)
DBSNP = file(params.DBSNP)
DBSNPidx = file(params.DBSNPidx)
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads
HaplotyperOutputDirectory = params.HaplotyperOutputDirectory
HaplotyperExtraOptions = params.HaplotyperExtraOptions
HaplotyperEnvProfile = file(params.HaplotyperEnvProfile)
DebugMode = params.DebugMode


/** Retrieve realigned bams from realignment output directory */
RealignmentOutputDirectory = params.RealignmentOutputDirectory
InputAlignedSortedDedupedRealignedBam = file(RealignmentOutputDirectory + "/" + SampleName + ".aligned.sorted.deduped.realigned.bam")
InputAlignedSortedDedupedRealignedBamBai = file(RealignmentOutputDirectory + "/" + SampleName + ".aligned.sorted.deduped.realigned.bam.bai")


/** Retrieve recalibration table from bqsr output directory */
BQSROutputDirectory = params.BQSROutputDirectory
RecalTable = file(BQSROutputDirectory + "/" + SampleName + ".recal_data.table")


/** Start haplotyper */
process Haplotyper{
 
   publishDir HaplotyperOutputDirectory, mode: "move"

   input:
	val Ref
//	file RefFai
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

   output:
	file "${SampleName}.haplotyper.TBD.log"
	file "${SampleName}.haplotype_sentieon.log"

   script:
       """
       /bin/bash ${HaplotyperScript} -s ${SampleName} -b ${InputAlignedSortedDedupedRealignedBam} -G ${Ref} -D ${DBSNP} -r ${RecalTable} -S ${Sentieon} -t ${SentieonThreads} -O ${HaplotyperOutputDirectory} -o ${HaplotyperFinalExtraOptions} -e ${HaplotyperEnvProfile}  ${DebugMode}
       """
}
