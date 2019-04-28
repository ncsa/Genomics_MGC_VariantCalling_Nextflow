/*******************************************************************************************/
/*                                                                                         */
/*              This Nextflow script performs VQSR using Sentieon                          */
/*                                                                                         */
/*                              Script Options                                             */
/*       -s        "Name of the sample"                        (Required)                  */
/*       -V        "Input VCF"                                 (Required)                  */
/*       -G        "Reference Genome"                          (Required)                  */
/*       -r        "VQSR SNP Resource String"                  (Required)                  */
/*       -R        "VQSR INDEL Resource String"                (Required)                  */
/*       -a        "Annotate text string"                      (Required)                  */
/*       -S        "Path to the Sentieon Tool"                 (Required)                  */
/*       -t        "Number of Threads"                         (Required)                  */
/*       -e        "Path to Environment Profile File"          (Required)                  */
/* 	 -O 	   "Path to Output Directory"		       (Required)		   */
/*       -d        "Debug Mode Specification"                  (Required)                  */
/*******************************************************************************************/

/** Nextflow option so bash stdout will be displayed */
echo true


/** Import variables */
VqsrScript = params.VqsrScript
SampleName = params.SampleName
Ref = params.Ref
//RefFai = file(params.RefFai)
VqsrSnpResourceString = params.VqsrSnpResourceString
VqsrIndelResourceString = params.VqsrIndelResourceString
AnnotateText = params.AnnotateText
Sentieon = params.Sentieon
SentieonThreads = params.SentieonThreads
VqsrEnvProfile = file(params.VqsrEnvProfile)
VqsrOutputDirectory = params.VqsrOutputDirectory
DebugMode = params.DebugMode


/** Retrieve VCF output from Haplotyper */
HaplotyperOutputDirectory = params.HaplotyperOutputDirectory
InputVCF = file(HaplotyperOutputDirectory + "/" + SampleName + ".vcf")
InputVCFIdx = file(HaplotyperOutputDirectory + "/" + SampleName + ".vcf.idx")

/** Start Vqsr */
process Vqsr {

   publishDir VqsrOutputDirectory, mode: "move"
   input:
	val Ref
//	file RefFai
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

   output:
	file "${SampleName}.vqsr_sentieon.log"
	file "${SampleName}.vqsr.TBD.log"
	file "${SampleName}.INDEL.VQSR.pdf" optional true
	file "${SampleName}.INDEL.plotfile" optional true
	file "${SampleName}.INDEL.recal" optional true
	file "${SampleName}.INDEL.recal.idx" optional true
	file "${SampleName}.INDEL.tranches" optional true
	file "${SampleName}.SNP.VQSR.pdf" optional true
	file "${SampleName}.SNP.plotfile" optional true
	file "${SampleName}.SNP.recal" optional true
	file "${SampleName}.SNP.recal.idx" optional true
	file "${SampleName}.SNP.recaled.vcf" optional true
	file "${SampleName}.SNP.recaled.vcf.idx" optional true
	file "${SampleName}.SNP.tranches" optional true

   script:
       """
       /bin/bash ${VqsrScript} -s ${SampleName} -V ${InputVCF} -G ${Ref} -r ${VqsrSnpResourceStringFinal} -R ${VqsrIndelResourceStringFinal} -a ${AnnotateTextFinal} -S ${Sentieon} -t ${SentieonThreads} -e ${VqsrEnvProfile} -O ${VqsrOutputDirectory} ${DebugMode}
       """
}
