/*****************************************************************************************/
/*                                                                                       */
/*              This Nextflow script trims the Inputs Fasta File using CutAdapt          */
/*                                                                                       */
/*                                    Script Options                                     */
/*         -t        "Number of Threads"                         (Required)              */ 
/*         -P        "Paired Ended Reads specification"          (Required)              */  
/*         -l        "Left Fastq File"                           (Required)              */
/*         -r        "Right Fastq File"                          (Optional)              */
/*         -s        "Name of the sample"                        (Optional)              */
/*         -A        "Adapter File for CutAdapt"                 (Required)              */
/*         -C        "Path to CutAdapt Tool"                     (Required)              */
/* 	   -e 	     "Path to the environmental profile"	 (Required)		 */
/*	   -d 	     "debug mode on/off"			 (Optional: can be empty)*/
/*****************************************************************************************/



echo true

InputRead1 = file(params.InputRead1)
InputRead2 = params.InputRead2
Adapters = file(params.Adapters)
CutAdapt = params.CutAdapt
CutAdaptThreads = params.CutAdaptThreads
PairedEnd = params.PairedEnd
DebugMode = params.DebugMode
SampleName = params.SampleName
TrimSeqScript = params.TrimSeqScript
DebugMode = params.DebugMode
TrimEnvProfile = params.TrimEnvProfile

process TrimSequences {

   input:
      file InputRead1             // Input Read File 
      val  InputRead2             // Input Read File            
      file Adapters               // Adapter FASTQ File
      val CutAdapt                // Path to CutAdapt Tool
      val CutAdaptThreads         // Number of threads
      val PairedEnd               // Is input FASTQ paired ended?
      val DebugMode               // Debug Mode
      val SampleName              // Name of the Sample
      val TrimSeqScript           // Bash script that actually runs the trimming program
      val TrimEnvProfile 	  // File containing the environmental profile variables

//   output:
//      file '${SampleName}.read1.trimmed.fq.gz' into trimmedFiles
//      file '${SampleName}.read2.trimmed.fq.gz' into trimmedFiles

   script:
      """
	echo InputRead1
	echo InputRead2
      /bin/bash $TrimSeqScript -P $PairedEnd -l $InputRead1 -r $InputRead2 -s $SampleName -A $Adapters -C $CutAdapt -t $CutAdaptThreads -e $TrimEnvProfile $DebugMode
      """

}

