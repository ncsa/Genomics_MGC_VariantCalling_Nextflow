/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs alignment using BWA Mem                      */
/*                                                                                         */
/*                              Script Options                                             */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -p        "Platform"                                  (Required)                  */
/*       -L	       "Library"        			               (Required)                  */
/*       -f        "Flow cell ID/Platform Unit"                (Required)                  */
/*       -c        "Sequencing Center"                         (Required)                  */
/*       -P        "Paired Ended Reads specification"          (Required)                  */
/*       -l        "Left Fastq File"                           (Required)                  */
/*       -r        "Right Fastq File"                          (Optional)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -e        "Path to bwa executable"                    (Required)                  */
/*       -K        "Chunk Size in Bases"                       (Required)                  */
/*       -o        "Additional bwa options"                    (Required)                  */
/*       -S        "Path to samtools executable"               (Required)                  */
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -F        "Shared function script"	                   (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*  	 -O 	   "Path to Output Directory" 		           (Required)	        	   */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo false


/** Import variables */
SampleName = params.SampleName							                // Sample name used for output
Platform = params.Platform							                    // Name of sequencing platform used for sequencing DNA
Library = params.Library	                    						// Library name
PlatformUnit = params.PlatformUnit                                      // Platform unit / flowcell ID for read group
CenterName = params.CenterName              	            			// Name of the sequencing center for read group
PairedEnd = params.PairedEnd							                // Is input FASTQ paired ended?
InputRead1 = params.InputRead1                                          // Input Read File
InputRead2 = params.InputRead2                                          // Input Read File
Ref = file(params.Ref)                  								// Reference genome
RefAmb = file(params.RefAmb)                                            // Reference indices
RefAnn = file(params.RefAnn)                                            // Reference indices
RefBwt = file(params.RefBwt)                                            // Reference indices
RefPac = file(params.RefPac)                                            // Reference indices
RefSa = file(params.RefSa)                                              // Reference indices
BWAExe = file(params.BWAExe)                                            // Path to BWA executable
ChunkSizeInBases = params.ChunkSizeInBases 	                    		// 10000000 to prevent different results based on thread count
BWAExtraOptionsString = params.BWAExtraOptionsString   			        // BWA extra options
SamtoolsExe = file(params.SamtoolsExe)                                  // Path to samtools executable
BwaSamtoolsThreads = params.BwaSamtoolsThreads                          // Specifies the number of thread required per run

BashSharedFunctions = file(params.BashSharedFunctions)	                // Shared function for variable checks
DebugMode = params.DebugMode							                // Flag to enable debug mode

BashPreamble = file(params.BashPreamble)                                // Bash script to help control zombie processes
AlignmentScript = file(params.AlignmentScript)				            // Bash script running alignment

AlignmentMultinode = params.AlignmentMultinode


InputRead1Channel = Channel.fromPath(InputRead1.tokenize(','))

if (InputRead2.contains(',')){
    InputRead2Channel = Channel.fromPath(InputRead2.tokenize(','))
} else {
    InputRead2Channel = InputRead2
}

PlatformUnitChannel = Channel.from(PlatformUnit.tokenize(','))

/** Start Alignment */

process Alignment{
	
	//label AlignmentMultinode == "true" && Multilane == true ? "AlignMN" : null

	input:
	val SampleName
	val Platform
    val Library
    val PlatformUnit from PlatformUnitChannel
    val CenterName
	val PairedEnd
	file InputRead1 from InputRead1Channel
	val InputRead2 from InputRead2Channel
	file Ref
	file RefAmb
	file RefAnn
	file RefBwt
	file RefPac
	file RefSa
    file BWAExe
	val ChunkSizeInBases
    val BWAExtraOptionsString
    file SamtoolsExe
	val BwaSamtoolsThreads
    file BashSharedFunctions
 	val DebugMode
    
    file BashPreamble
	file AlignmentScript


	script:
	if (PairedEnd == "true")
	       """
           source ${BashPreamble}
	       /bin/bash ${AlignmentScript} -s ${SampleName} -p ${Platform} -L ${Library} -f ${PlatformUnit} -c ${CenterName} -P ${PairedEnd} -l ${InputRead1} -r ${InputRead2} -G ${Ref} -e ${BWAExe} -K ${ChunkSizeInBases} -o \"\'${BWAExtraOptionsString}\'\" -S ${SamtoolsExe} -t ${BwaSamtoolsThreads} -F ${BashSharedFunctions}  ${DebugMode}
	       """

	else
	       """
	       source ${BashPreamble}
	       /bin/bash ${AlignmentScript} -s ${SampleName} -p ${Platform} -L ${Library} -f ${PlatformUnit} -c ${CenterName} -P ${PairedEnd} -l ${InputRead1} -r "null" -G ${Ref} -e ${BWAExe} -K ${ChunkSizeInBases} -o \"\'${BWAExtraOptionsString}\'\" -S ${SamtoolsExe} -t ${BwaSamtoolsThreads} -F ${BashSharedFunctions}  ${DebugMode}
	       """
}
