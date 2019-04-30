/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script marks the duplicates on input sorted BAMs             */
/*                                                                                         */
/*******************************************************************************************/

/***************         Nextflow option so bash stdout will be displayed       ************/
echo true


/************************                Import variables               ********************/
SampleName = params.SampleName					// Sample name used for output

InputBams = file(params.InputBams)              // Input Sorted BAM File
InputBais = file(params.InputBais)              // Input Sorted Bam Index File

GATKExe = file(params.GATKExe)					// GATK executable path
JavaExe = file(params.JavaExe)                  // Java executable path
JavaOptionsString = params.JavaOptionsString    //String of java vm options 

DebugMode = params.DebugMode					// Debug mode

BashPreamble = file(params.BashPreamble)        // shell file to source before each process
BashSharedFunctions = file(params.BashSharedFunctions) // Bash script with shared functions

DedupScript = file(params.DedupScript)				// Bash script running deduplication


/**********************           Define Dedup process                **********************/

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
       /bin/bash ${DedupScript} -s ${SampleName} -b ${InputBams} -S ${GATKExe} -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} {DebugMode}
       """
}
