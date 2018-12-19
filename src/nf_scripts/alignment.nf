/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs alignment using BWA Mem                      */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -P        "Paired Ended Reads specification"          (Required)                  */
/*       -l        "Left Fastq File"                           (Required)                  */
/*       -r        "Right Fastq File"                          (Optional)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */ 
/*       -g        "Group"                                     (Required)                  */
/*       -p        "Platform"                                  (Required)                  */
/*       -K        "Chunk Size in Bases"                       (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

echo true

Ref = file(params.Ref)
RefAmb = file(params.RefAmb)
RefAnn = file(params.RefAnn)
RefBwt = file(params.RefBwt)
RefPac = file(params.RefPac)
RefSa = file(params.RefSa)

InputRead1 = file(params.InputRead1)
InputRead2 = file(params.InputRead2)
AlignEnvProfile = file(params.AlignEnvProfile)

SampleName = params.SampleName
Group = params.Group
Platform = params.Platform
PairedEnd = params.PairedEnd
ChunkSize = params.ChunkSize
SentieonThreads = params.SentieonThreads

AlignmentScript = params.AlignmentScript
Sentieon = params.Sentieon

DebugMode = params.DebugMode

process Alignment{
   input:
       file Ref
       file RefAmb
       file RefAnn
       file RefBwt
       file RefPac
       file RefSa
       
       file InputRead1
       file InputRead2
       file AlignEnvProfile      

       val SampleName
       val Group
       val Platform
       val PairedEnd
       val ChunkSize
       val SentieonThreads

       val AlignmentScript      
       val Sentieon       

       val DebugMode

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles 
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       """
       /bin/bash ${AlignmentScript} -P ${PairedEnd} -g ${Group} -l ${InputRead1} -r ${InputRead2} -s ${SampleName} -p ${Platform} -G ${Ref} -K ${ChunkSize} -S ${Sentieon} -t ${SentieonThreads} -e ${AlignEnvProfile}  ${DebugMode} 
       """
}
