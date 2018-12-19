/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script marks the duplicates on input sorted BAMs             */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Required)                  */
/*       -b        "Input BAM File"                            (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -O        "Directory for the Output"                  (Required)                  */ 
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

echo true

InputAlignedSortedBam = file(params.InputAlignedSortedBam)
InputAlignedSortedBamBai = file(params.InputAlignedSortedBamBai)

DedupEnvProfile = file(params.DedupEnvProfile)

SampleName = params.SampleName
SentieonThreads = params.SentieonThreads

DedupScript = params.DedupScript
Sentieon = params.Sentieon

DebugMode = params.DebugMode

process Deduplication{
   input:
       file InputAlignedSortedBam
       file InputAlignedSortedBamBai
       
       file DedupEnvProfile      

       val SampleName
       val SentieonThreads

       val DedupScript      
       val Sentieon       

       val DebugMode

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles 
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       """
       /bin/bash ${DedupScript} -b ${InputAlignedSortedBam} -s ${SampleName} -S ${Sentieon} -t ${SentieonThreads} -e ${DedupEnvProfile}  ${DebugMode} 
       """
}
