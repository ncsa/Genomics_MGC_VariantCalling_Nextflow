/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs VQSR using Sentieon                          */
/*                                                                                         */
/*                              Script Options                                             */
/*       -t        "Number of Threads"                         (Required)                  */
/*       -V        "Input VCF"                                 (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -s        "Name of the sample"                        (Required)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/* 	 -D 	   "Path to Output Directory"		       (Required)		   */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

echo true

Ref = file(params.Ref)
RefFai = file(params.RefFai)

InputVCF = file(params.InputVCF)
InputVCFIdx = file(params.InputVCFIdx)

SampleName = params.SampleName

VqsrSnpResourceString = params.VqsrSnpResourceString
VqsrIndelResourceString = params.VqsrIndelResourceString
AnnotateText = params.AnnotateText

Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads

VqsrScript = params.VqsrScript
VqsrEnvProfile = file(params.VqsrEnvProfile)
VqsrOutputDirectory = params.VqsrOutputDirectory

DebugMode = params.DebugMode

process Vqsr{
   input:
	file Ref
	file RefFai
	file InputVCF
	file InputVCFIdx
	
	file VqsrEnvProfile
	val VqsrScript
	val VqsrOutputDirectory

	val VqsrSnpResourceString
	String VqsrSnpResourceStringFinal = "\"" + VqsrSnpResourceString + "\""
	val VqsrIndelResourceString
	String VqsrIndelResourceStringFinal = "\"" + VqsrIndelResourceString + "\""
	val AnnotateText
	String AnnotateTextFinal = "\"" + AnnotateText + "\""

	val SampleName
	val SentieonThreads
	val Sentieon
	val DebugMode

//   output
//      '${SampleName}.aligned.sorted.bam' into alignedFiles
//      '${SampleName}.aligned.sorted.bam.bai' into alignedFiles

   script:
       """
       /bin/bash ${VqsrScript} -s ${SampleName} -V ${InputVCF} -G ${Ref} -r ${VqsrSnpResourceStringFinal} -R ${VqsrIndelResourceStringFinal} -a ${AnnotateTextFinal} -S ${Sentieon} -t ${SentieonThreads} -e ${VqsrEnvProfile} -D ${VqsrOutputDirectory} ${DebugMode}
       """
}
