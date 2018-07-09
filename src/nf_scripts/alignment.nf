/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs alignment using BWA Mem                      */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Optional)                  */
/*       -P        "Single Ended Reads specification"          (Required)                  */
/*       -l        "Left Fastq File"                           (Required)                  */
/*       -r        "Right Fastq File"                          (Optional)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -s        "Name of the sample"                        (Optional)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */ 
/*       -L        "Sentieon License File"                     (Required)                  */
/*       -g        "Group"                                     (Required)                  */
/*       -p        "Platform"                                  (Required)                  */
/*******************************************************************************************/

echo true

Ref = file(params.Ref)
InputRead1 = file(params.InputRead1)
InputRead2 = file(params.InputRead2)
SampleName = params.SampleName

RefAmb = file(params.RefAmb)
RefAnn = file(params.RefAnn)
RefBwt = file(params.RefBwt)
RefPac = file(params.RefPac)
RefSa = file(params.RefSa)

SentieonLicense = params.SentieonLicense
Sentieon = params.Sentieon

Group = params.Group
Platform = params.Platform
DebugMode = params.DebugMode
Threads = params.Threads

PairedEnd = params.PaieredEnd

AlignmentScript = params.AlignmentScript

process alignment{
   input:
       file Ref
       file InputRead1
       file InputRead2
       file SampleName
 
       file RefAmb
       file RefAnn
       file RefBwt
       file RefPac
       file RefSa
 
       val SentieonLicense
       val Sentieon
 
       val Group
       val Platform
       val DebugMode
       val Threads

       val PairedEnd

       val AlignmentScript

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles 
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       ###
       /bin/bash ${AlignmentScript} -L ${SentieonLicense} -P ${PairedEnd} -g ${Group} -l ${InputRead1} -r ${InputRead2} -s ${SampleName} -p ${Platform} -G ${Ref} -S ${Sentieon} -t ${Threads} ${DebugMode}
       ###
}
