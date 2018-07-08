/*****************************************************************************************/
/*                                                                                       */
/*              This Nextflow script trims the Inputs Fasta File using CutAdapt          */
/*                                                                                       */
/*                                    Script Options                                     */
/*         -t        "Number of Threads"                         (Required)              */ 
/*         -P        "Single Ended Reads specification"          (Required)              */  
/*         -r        "Left Fastq File"                           (Required)              */
/*         -R        "Right Fastq File"                          (Optional)              */
/*         -s        "Name of the sample"                        (Optional)              */
/*         -A        "Adapter File for CutAdapt"                 (Required)              */
/*         -C        "Path to CutAdapt Tool"                     (Required)              */
/*****************************************************************************************/



echo true

InputRead1 = file(params.InputRead1)
InputRead2 = file(params.InputRead2)
Adapters = file(params.Adapters)
CutAdapt = params.CutAdapt
Threads = params.Threads
PairedEnd = params.PairedEnd
DebugMode = params.DebugMode
SampleName = params.SampleName
TrimSeqScript = params.TrimSeqScript


process novosort {

   input:
      file InputRead1             // Input Read File 
      val  InputRead2             // Input Read File            
      file Adapters               // Adapter FASTQ File
      val CutAdapt               // Path to CutAdapt Tool
      val Threads                 // Number of threads
      val PairedEnd               // Is input FASTQ paired ended?
      val DebugMode               // Debud Mode
      val SampleName              // Name of the Sample
      val TrimSeqScript          // Bash script that actually runs the trimming program

//   output:
//      file '${SampleName}.read1.trimmed.fq.gz' into trimmedFiles
//      file '${SampleName}.read2.trimmed.fq.gz' into trimmedFiles

   script:
      """
      /bin/bash $TrimSeqScript -P $PairedEnd -l $InputRead1 -r $InputRead2 -s $SampleName -A $Adapters -C $CutAdapt -t $Threads $DebugMode
      """

}
