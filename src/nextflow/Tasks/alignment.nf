/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs alignment using BWA Mem                      */
/*                                                                                         */
/*                              Script Options                                             */
/*       -P        "Paired Ended Reads specification"          (Required)                  */
/*       -l        "Left Fastq File"                           (Required)                  */
/*       -r        "Right Fastq File"                          (Optional)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -p        "Platform"                                  (Required)                  */
/*       -f        "Platform Unit"                             (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -K        "Chunk Size in Bases"                       (Required)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */ 
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -F        "Shared function script"	               (Required)                  */
/*       -L	   "Library"			               (Required)                  */
/*       -L        "Sequencing Center"                         (Required)                  */
/*	 -O 	   "Path to Output Directory" 		       (Required)		   */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import variables */
AlignmentMultinode = params.AlignmentMultinode
AlignmentScript = params.AlignmentScript					// Bash script running alignment
PairedEnd = params.PairedEnd							// Is input FASTQ paired ended?
Trim_sequencesOutputDirectory = params.Trim_sequencesOutputDirectory		// Ouput folder from Trimming step
SampleName = params.SampleName							// Sample name used for output
Platform = params.Platform							// Name of sequencing platform used for sequencing DNA 
Ref = file(params.Ref)								// Reference genome
RefAmb = file(params.RefAmb)                                                    // Reference indices
RefAnn = file(params.RefAnn)                                                    // Reference indices
RefBwt = file(params.RefBwt)                                                    // Reference indices
RefPac = file(params.RefPac)                                                    // Reference indices
RefSa = file(params.RefSa)                                                      // Reference indices
ChunkSize = params.ChunkSize							// 10000000 to prevent different results based on thread count
Sentieon = params.Sentieon							// Sentieon executable
SentieonThreads = params.SentieonThreads					// Number of threads for alignment
AlignEnvProfile = file(params.AlignEnvProfile)					// File containing environmental profile variables
SharedFunctionScript = params.NextflowShellDir  + "/shared_functions.sh"	// Shared function for variable checks
Library = params.Library							// Library name
SequencingCenter = params.SequencingCenter					// Sequencing center
BWAExtraOption = params.BWAExtraOption						// BWA extra options
AlignmentOutputDirectory = params.AlignmentOutputDirectory			// Output directory for alignment
DebugMode = params.DebugMode							// Debug mode


/** Add flag variable indicating if the samples are multilane */
InputRead1 = params.InputRead1
Multilane = false
if (InputRead1.contains(',')) {
        Multilane = true
}


/** Channel sample preparation for Alignment */
trimmedInputRead1List = []
trimmedInputRead2List = []

new File(Trim_sequencesOutputDirectory).eachFile() {

	file -> if (file.name.contains("read1.")) {
			trimmedInputRead1List.add(file.getAbsolutePath())

		} else if (file.name.contains("read2")) {
			trimmedInputRead2List.add(file.getAbsolutePath())

		}
}


/** Make lane list for lane information */
trimmedInputRead1List = trimmedInputRead1List.sort()
if (trimmedInputRead1List.size() != 0 ) {
	laneList = (1..trimmedInputRead1List.size()).collect{it.toString()}
	laneList = (laneList.sort())

} else {
	laneList = [0]

}

laneChannel = Channel.from(laneList)
trimmedInputRead1Channel = Channel.from(trimmedInputRead1List)
InputRead1 = params.InputRead1



/** Start Alignment */
if (PairedEnd == "true") {

	trimmedInputRead2List = trimmedInputRead2List.sort()
	trimmedInputRead2Channel = Channel.from(trimmedInputRead2List)

	process AlignmentPairedEnd{
		
		label AlignmentMultinode == "true" && Multilane == true ? "AlignMN" : null

		input:
		file Ref
		file RefAmb
		file RefAnn
		file RefBwt
		file RefPac
		file RefSa

		val TrimmedInputRead1 from trimmedInputRead1Channel
		val TrimmedInputRead2 from trimmedInputRead2Channel
		val laneNumber from laneChannel
		file AlignEnvProfile      

		val SampleName
		val Platform
		val PairedEnd
		val ChunkSize
		val SentieonThreads

		val AlignmentScript      
		val AlignmentOutputDirectory
		val Sentieon       

		val DebugMode

	     
		script:
		if (Multilane == true)
		       """
		       /bin/bash ${AlignmentScript} -P ${PairedEnd} -l ${TrimmedInputRead1} -r ${TrimmedInputRead2} -s ${SampleName}Lane${laneNumber}.aligned.sorted -p ${Platform} -f ${Platform}Lane${laneNumber} -G ${Ref} -K ${ChunkSize} -S ${Sentieon} -t ${SentieonThreads} -e ${AlignEnvProfile} -F ${SharedFunctionScript} -L ${Library} -c ${SequencingCenter} -o \"\'${BWAExtraOption}\'\" ${DebugMode}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.bam ${AlignmentOutputDirectory}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.bam.bai ${AlignmentOutputDirectory} 
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.align_sentieon.log ${AlignmentOutputDirectory}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.alignment.TBD.log ${AlignmentOutputDirectory}	 
		       """

		else
		       """     
		       /bin/bash ${AlignmentScript} -P ${PairedEnd} -l ${TrimmedInputRead1} -r ${TrimmedInputRead2} -s ${SampleName}.aligned.sorted -p ${Platform} -f ${Platform} -G ${Ref} -K ${ChunkSize} -S ${Sentieon} -t ${SentieonThreads} -e ${AlignEnvProfile} -F ${SharedFunctionScript} -L ${Library} -c ${SequencingCenter} -o \"\'${BWAExtraOption}\'\" ${DebugMode} 
		       mv ${SampleName}.aligned.sorted.bam ${AlignmentOutputDirectory}
		       mv ${SampleName}.aligned.sorted.bam.bai ${AlignmentOutputDirectory}
		       mv ${SampleName}.aligned.sorted.align_sentieon.log ${AlignmentOutputDirectory}
		       mv ${SampleName}.aligned.sorted.alignment.TBD.log ${AlignmentOutputDirectory}	 
		       """  
	}

} else if (PairedEnd == "false") {
        process AlignmentSingleEnd{

		label AlignmentMultinode == "true" && Multilane == true ? "AlignMN" : null

		input:
		file Ref
		file RefAmb
		file RefAnn
		file RefBwt
		file RefPac
		file RefSa

		val TrimmedInputRead1 from trimmedInputRead1Channel
		val laneNumber from laneChannel
		file AlignEnvProfile

		val SampleName
		val Platform
		val PairedEnd
		val ChunkSize
		val SentieonThreads

		val AlignmentScript
		val AlignmentOutputDirectory
		val Sentieon

		val DebugMode

		script:

		if (Multilane == true)
		       """
		       /bin/bash ${AlignmentScript} -P ${PairedEnd} -l ${TrimmedInputRead1} -r "null" -s ${SampleName}Lane${laneNumber}.aligned.sorted -p ${Platform} -f ${Platform}Lane${laneNumber} -G ${Ref} -K ${ChunkSize} -S ${Sentieon} -t ${SentieonThreads} -e ${AlignEnvProfile} -F ${SharedFunctionScript} -L ${Library} -c ${SequencingCenter} -o \"\'${BWAExtraOption}\'\" ${DebugMode}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.bam ${AlignmentOutputDirectory}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.bam.bai ${AlignmentOutputDirectory}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.align_sentieon.log ${AlignmentOutputDirectory}
		       mv ${SampleName}Lane${laneNumber}.aligned.sorted.alignment.TBD.log ${AlignmentOutputDirectory}
		       """

		else
		       """
		       /bin/bash ${AlignmentScript} -P ${PairedEnd} -l ${TrimmedInputRead1} -r "null" -s ${SampleName}.aligned.sorted -p ${Platform} -f ${Platform} -G ${Ref} -K ${ChunkSize} -S ${Sentieon} -t ${SentieonThreads} -e ${AlignEnvProfile} -F ${SharedFunctionScript} -L ${Library} -c ${SequencingCenter} -o \"\'${BWAExtraOption}\'\" ${DebugMode}
		       mv ${SampleName}.aligned.sorted.bam ${AlignmentOutputDirectory}
		       mv ${SampleName}.aligned.sorted.bam.bai ${AlignmentOutputDirectory}
		       mv ${SampleName}.aligned.sorted.align_sentieon.log ${AlignmentOutputDirectory}
		       mv ${SampleName}.aligned.sorted.alignment.TBD.log ${AlignmentOutputDirectory}
		       """
	}
}


