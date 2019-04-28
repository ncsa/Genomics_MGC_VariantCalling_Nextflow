/*****************************************************************************************/
/*                                                                                       */
/*              This Nextflow script trims the Inputs Fasta File using CutAdapt          */
/*                                                                                       */
/*                                    Script Options                                     */
/*         -P        "Paired Ended Reads specification"          (Required)              */  
/*         -l        "Left Fastq File"                           (Required)              */
/*         -r        "Right Fastq File"                          (Optional)              */
/*         -s        "Name of the sample"                        (Optional)              */
/*         -A        "Adapter File for CutAdapt"                 (Required)              */
/*         -C        "Path to CutAdapt Tool"                     (Required)              */
/*         -t        "Number of Threads"                         (Required)              */ 
/* 	   -e 	     "Path to the environmental profile"	 (Required)		 */
/* 	   -O 	     "Path to the output directory" 		 (Required)	 	 */
/*	   -d 	     "debug mode on/off"			 (Optional: can be empty)*/
/*****************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import Variables */
TrimMultinode = params.TrimMultinode
TrimSeqScript = params.TrimSeqScript						// Bash script that actually runs the trimming program
PairedEnd = params.PairedEnd							// Is input FASTQ paired ended?
InputRead1 = params.InputRead1							// Sample left read input(s) 
InputRead2 = params.InputRead2							// Sample right read input(s)
SampleName = params.SampleName							// Sample name used for output
Adapters = file(params.Adapters)						// Adapter FASTQ File
CutAdapt = params.CutAdapt							// Path to CutAdapt Tool
CutAdaptThreads = params.CutAdaptThreads					// Threads that will be used for CutAdapt
TrimEnvProfile = params.TrimEnvProfile						// File containing environmental profile variables
Trim_sequencesOutputDirectory = params.Trim_sequencesOutputDirectory		// Output Directory for Trim sequences Process
DebugMode = params.DebugMode							// Debug Mode


/** Add flag variable indicating if the samples are multilane */
Multilane = false
if (InputRead1.contains(',')) {
	Multilane = true
}


/** Prepare channels to separate lanes */
if (Multilane == true) {

	InputRead1List = InputRead1.split(',')
	LaneList = (1..(InputRead1List.size()))

} else {

	InputRead1List = InputRead1
	LaneList = 1

}


if (PairedEnd == "true") {

	if (Multilane == true) {
		InputRead2List = InputRead2.split(',')

	} else {
		InputRead2List = InputRead2

	}

	process TrimSequencesPairedEnd {

		label TrimMultinode == "true" && Multilane == true ? "TrimMN" : null

                input:
                val TrimSeqScript                                       // Bash script that actually runs the trimming program
                val PairedEnd                                           // Is input FASTQ paired ended?
                val InputRead1 from Channel.from(InputRead1List)        // Input Read 1 File
		val InputRead2 from Channel.from(InputRead2List)	// Input Read 2 File
                val SampleName                                          // Name of the Sample
		val laneNumber from Channel.from(LaneList)
                file Adapters                                           // Adapter FASTQ File
                val CutAdapt                                            // Path to CutAdapt Tool
                val CutAdaptThreads                                     // Number of threads
                val TrimEnvProfile                                      // File containing the environmental profile variables
                val Trim_sequencesOutputDirectory                       // Directory where the outputs will be placed
                val DebugMode                                           // Debug Mode

		script:
		if (Multilane == true)
			"""
			/bin/bash $TrimSeqScript -P $PairedEnd -l $InputRead1 -r $InputRead2 -s ${SampleName}Lane${laneNumber} -A $Adapters -C $CutAdapt -t $CutAdaptThreads -e $TrimEnvProfile -O $Trim_sequencesOutputDirectory $DebugMode
                        mv ${SampleName}Lane${laneNumber}.cutadapt.log $Trim_sequencesOutputDirectory
                        mv ${SampleName}Lane${laneNumber}.trimming.TBD.log $Trim_sequencesOutputDirectory
			"""
                else
			"""
			/bin/bash $TrimSeqScript -P $PairedEnd -l $InputRead1 -r $InputRead2 -s ${SampleName} -A $Adapters -C $CutAdapt -t $CutAdaptThreads -e $TrimEnvProfile -O $Trim_sequencesOutputDirectory $DebugMode
                        mv ${SampleName}.cutadapt.log $Trim_sequencesOutputDirectory
                        mv ${SampleName}.trimming.TBD.log $Trim_sequencesOutputDirectory
			"""
	}

}


else if (PairedEnd == "false") {

        process TrimSequencesSingleEnd {

		label TrimMultinode == "true" && Multilane == true ? "TrimMN" : null	

                input:
	     	val TrimSeqScript           				// Bash script that actually runs the trimming program
	      	val PairedEnd               				// Is input FASTQ paired ended?
                val InputRead1 from Channel.from(InputRead1List) 	// Input Read 1 File
		val laneNumber from Channel.from(LaneList)
	      	val SampleName              				// Name of the Sample
		file Adapters               				// Adapter FASTQ File
	      	val CutAdapt                				// Path to CutAdapt Tool
	      	val CutAdaptThreads         				// Number of threads
	      	val TrimEnvProfile          				// File containing the environmental profile variables
	      	val Trim_sequencesOutputDirectory     			// Directory where the outputs will be placed
	      	val DebugMode             				// Debug Mode
	
                script:
                if (Multilane == true)
			"""
			/bin/bash $TrimSeqScript -P $PairedEnd -l $InputRead1 -r "null" -s ${SampleName}Lane${laneNumber} -A $Adapters -C $CutAdapt -t $CutAdaptThreads -e $TrimEnvProfile -O $Trim_sequencesOutputDirectory $DebugMode
			mv ${SampleName}Lane${laneNumber}.cutadapt.log $Trim_sequencesOutputDirectory
			mv ${SampleName}Lane${laneNumber}.trimming.TBD.log $Trim_sequencesOutputDirectory
			"""

		else
			"""
			/bin/bash $TrimSeqScript -P $PairedEnd -l $InputRead1 -r "null" -s ${SampleName} -A $Adapters -C $CutAdapt -t $CutAdaptThreads -e $TrimEnvProfile -O $Trim_sequencesOutputDirectory $DebugMode
                        mv ${SampleName}.cutadapt.log $Trim_sequencesOutputDirectory
                        mv ${SampleName}.trimming.TBD.log $Trim_sequencesOutputDirectory
			"""
        }
}
