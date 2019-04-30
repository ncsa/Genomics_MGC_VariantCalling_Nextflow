/*********************************************************************************************/
/*                                                                                           */
/*               This Nextflow script marks the duplicates on input sorted BAMs              */
/*                                                                                           */
/*********************************************************************************************/

/* *******************       Nextflow option so bash stdout will be displayed     ********** */
echo true

/* *********************         Import input variables                ********************* */
SampleName = params.SampleName							// Sample name used for output
InputBams = params.InputBams                            // Input Sorted BAM Files
InputBais = params.InputBais                            // Input Sorted Bam Index Files
SamtoolsExe = file(params.SamtoolsExe)                  // Path to Samtools Executable

DebugMode = params.DebugMode							// Debug mode

BashPreamble = file(params.BashPreamble)                // Script for zombie processes
BashSharedFunctions = file(params.BashSharedFunctions)  // Script of helpful functions

MergeBamScript = params.MergeBamScript						// Bash script running merge BAMs
AlignmentOutputDirectory = params.AlignmentOutputDirectory	// Alignment dir (inputs)

/* *********************           Input channels preparation           ********************* */

//bamChannel = Channel.fromPath(AlignmentOutputDirectory + "/*.aligned.sorted.bam").collect()
//indexChannel=Channel.fromPath(AlignmentOutputDirectory+"/*.aligned.sorted.bam.bai").collect()

InputBamsChannel = InputBams 
InputBaisChannel = Channel.fromPath(InputBais.tokenize(',')).collect()

/* *********************            Start Merge process                ********************* */

process merge {

	input:
        val InputBam from InputBamsChannel
        file InputBai from InputBaisChannel
	
		"""
        source ${BashPreamble}
		/bin/bash ${MergeBamScript} -b ${InputBam} -s ${SampleName} -S ${SamtoolsExe} -F ${BashSharedFunctions} ${DebugMode}
		"""
}



