/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script marks the duplicates on input sorted BAMs             */
/*                                                                                         */
/*                              Script Options                                             */
/*       -b        "Input BAM File"                            (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */ 
/*       -t        "Number of Threads"                         (Required)                  */
/* 	 -O 	   "Path to Output Directory"		       (Required)		   */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import variables */
DedupScript = params.DedupScript				// Bash script running deduplication
SampleName = params.SampleName					// Sample name used for output
Sentieon = params.Sentieon					// Sentieon executable
SentieonThreads = params.SentieonThreads			// Number of threads for deduplication
DedupEnvProfile = file(params.DedupEnvProfile)			// File containing environmental profile variable
DedupOutputDirectory = params.DedupOutputDirectory		// Output directory for deduplication
DebugMode = params.DebugMode					// Debug mode


/** Add flag variable indicating if the samples are multilane */
InputRead1 = params.InputRead1
Multilane = false
if (InputRead1.contains(',')) {
        Multilane = true
}


/** Retrieves input bams, from merge output directory if multilane and alignment output directory if single-lane */
if (Multilane == true) {
	MergeOutputDirectory = params.MergeOutputDirectory
	InputAlignedSortedBam = file(MergeOutputDirectory + "/" +  SampleName + ".aligned.sorted.merged.bam")
	InputAlignedSortedBamBai = file(MergeOutputDirectory + "/" +  SampleName + "*.aligned.sorted.merged.bam.bai")

} else {
	AlignmentOutputDirectory = params.AlignmentOutputDirectory
	InputAlignedSortedBam = file(AlignmentOutputDirectory + "/" +  SampleName + ".aligned.sorted.bam")
	InputAlignedSortedBamBai = file(AlignmentOutputDirectory + "/" +  SampleName + ".aligned.sorted.bam.bai")
}

	
/** Start Deduplication */
process Deduplication{
   input:
       file InputAlignedSortedBam
       file InputAlignedSortedBamBai
       
       file DedupEnvProfile      

       val SampleName
       val SentieonThreads

       val DedupScript      
       val DedupOutputDirectory
       val Sentieon       

       val DebugMode

   script:
       """
       /bin/bash ${DedupScript} -b ${InputAlignedSortedBam} -s ${SampleName} -S ${Sentieon} -t ${SentieonThreads} -O ${DedupOutputDirectory} -e ${DedupEnvProfile}  ${DebugMode}
       mv ${SampleName}.dedup.TBD.log $DedupOutputDirectory
       mv ${SampleName}.dedup_metrics.txt $DedupOutputDirectory
       mv ${SampleName}.dedup_sentieon.log $DedupOutputDirectory
       mv ${SampleName}.deduped.score.txt $DedupOutputDirectory
       mv ${SampleName}.deduped.score.txt.idx $DedupOutputDirectory
       """
}
