/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs alignment using BWA Mem                      */
/*                                                                                         */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true

/* *********************         Import input variables       ********************* */
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

DeliveryFolder_Alignment = params.DeliveryFolder_Alignment

/* *********************         Prepare input channels       ********************* */
InputRead1Channel = Channel.fromPath(InputRead1.tokenize(','))

InputRead2Channel = ( PairedEnd == 'true' 
                      ? Channel.fromPath(InputRead2.tokenize(','))
                      : file('null').fileName )


PlatformUnitChannel = Channel.from(PlatformUnit.tokenize(','))

/* *********************         Start alignment process       ********************* */

process Alignment{

    publishDir DeliveryFolder_Alignment, mode: 'copy'

	input:
    	val SampleName
    	val Platform
        val Library
        val PlatformUnit from PlatformUnitChannel
        val CenterName
    	val PairedEnd
    	file InputRead1 from InputRead1Channel
    	file InputRead2 from InputRead2Channel
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

    output:
        file "${SampleName}.${PlatformUnit}.bam"  
        file "${SampleName}.${PlatformUnit}.bam.bai" 

    script:
       	"""
        source ${BashPreamble}
        /bin/bash ${AlignmentScript} -s ${SampleName}.${PlatformUnit} -p ${Platform} -L ${Library} -f ${PlatformUnit} -c ${CenterName} -P ${PairedEnd} -l ${InputRead1} -r ${InputRead2} -G ${Ref} -e ${BWAExe} -K ${ChunkSizeInBases} -o \"\'${BWAExtraOptionsString}\'\" -S ${SamtoolsExe} -t ${BwaSamtoolsThreads} -F ${BashSharedFunctions}  ${DebugMode}
        """
}
