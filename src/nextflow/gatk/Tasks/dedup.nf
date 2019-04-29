/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script marks the duplicates on input sorted BAMs             */
/*                                                                                         */
/*                              Script Options                                             */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -b        "Input BAM File"                            (Required)                  */
/*       -S        "Path to the GATK executable"               (Required)                  */ 
/*       -J        "Path to the java8 executable"              (Required)                  */
/*       -e        "Java Runtime options"                      (Required)                  */
/*       -F        "Path to shared_functions.sh"               (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import variables */
SampleName = params.SampleName					// Sample name used for output

InputBams = file(params.InputBams)              // Input Sorted BAM File
InputBais = file(params.InputBais)              // Input Sorted Bam Index File

GATKExe = file(params.GATKExe)					// GATK executable path
JavaExe = file(params.JavaExe)                  // Java executable path
JavaOptionsString = params.JavaOptionsString    //String of java vm options: garbage collection and max/min memory... Can NOT be empty

DebugMode = params.DebugMode					// Debug mode

BashPreamble = file(params.BashPreamble)        // shell file to source before each process
BashSharedFunctions = file(params.BashSharedFunctions) // Bash script with shared functions

DedupScript = params.DedupScript				// Bash script running deduplication

process Deduplication{
   input:
       val SampleName

       file InputBams
       file InputBais

       file GATKExe       
       file JavaExe
       val JavaOptionsString
      
       val DebugMode

       file BashPreamble
       file BashSharedFunctions

       file DedupScript      

   script:
       """
       source ${BashPreamble}
       /bin/bash ${DedupScript} -s ${SampleName} -b ${InputBams} -S ${GATKExe} -J ${JavaExe} -e ${JavaOptionsString} -F ${BashSharedFunctions} {DebugMode}
       """
}
