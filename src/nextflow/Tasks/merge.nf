/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script marks the duplicates on input sorted BAMs             */
/*                                                                                         */
/*                              Script Options                                             */
/*       -b        "Input BAM Files"                           (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -t        "Number of Threads"                         (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -F        "Shared function script"                    (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/
/** Nextflow option so bash stdout will be displayed */
echo true

/** Import variables */
MergeScript = params.MergeScript						// Bash script running merge BAMs
AlignmentOutputDirectory = params.AlignmentOutputDirectory			// Output folder for alignment (file source dir)
SampleName = params.SampleName							// Sample name used for output
Sentieon = params.Sentieon							// Sentieon executable
SentieonThreads = params.SentieonThreads					// Number of threads for sentieon merge BAMs
MergeOutputDirectory = params.MergeOutputDirectory				// Output folder for merge (destination dir)
MergeEnvProfile = params.MergeEnvProfile					// File containing environmental profile variables
SharedFunctionScript = params.NextflowShellDir  + "/shared_functions.sh"	// Shared function for variable checks
DebugMode = params.DebugMode							// Debug mode

/** Channel Preparation for merge bam files*/
bamChannel = Channel.fromPath(AlignmentOutputDirectory + "/*.aligned.sorted.bam").collect()
indexChannel = Channel.fromPath(AlignmentOutputDirectory + "/*.aligned.sorted.bam.bai").collect()


/** Add flag variable indicating if the samples are multilane */
InputRead1 = params.InputRead1
Multilane = false
if (InputRead1.contains(',')) {
	Multilane = true
}


/** Make lane list for lane information */
if (Multilane == true) { 
        InputRead1List = InputRead1.split(',')
        LaneList = (1..(InputRead1List.size()))
} else {
        InputRead1List = InputRead1
        LaneList = 1
}


/** Start merge */
process merge {

	input:
	file bams from bamChannel
	file indexFiles from indexChannel
		
	script:
	if (Multilane == true)
		"""
		bamSample="${bams}"
		bamSampleCommaDelim=\${bamSample// /,}
		/bin/bash ${MergeScript} -b \${bamSampleCommaDelim} -s ${SampleName}.aligned.sorted.merged -S ${Sentieon} -t ${SentieonThreads} -e ${MergeEnvProfile} -F ${SharedFunctionScript} ${DebugMode}
		mv ${SampleName}.aligned.sorted.merged.bam ${MergeOutputDirectory}
		mv ${SampleName}.aligned.sorted.merged.bam.bai ${MergeOutputDirectory}
		mv ${SampleName}.aligned.sorted.merged.merge_bams.TBD.log ${MergeOutputDirectory}
		mv ${SampleName}.aligned.sorted.merged.merge_bams_sentieon.log ${MergeOutputDirectory}
		"""

	else 
		"""
		echo "Single lane only, nothing to merge"
		"""
}



