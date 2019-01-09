echo true

nextflowRunFolder = "/projects/bioinformatics/PrakruthiWork/NextflowRuns"

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
TrimOutputDirectory = params.TrimOutputDirectory

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
      	 val TrimEnvProfile          // File containing the environmental profile variables
      	 val TrimOutputDirectory
	
	output:
	trimSequencesOutputFile = Channel.fromPath(nextflowRunFolder+"*trimmed.*")
	stdout into trimSequencesOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/trim_sequences.nf  
	"""
}

process Alignment {
	input:
	val preAlignmentFlag from trimSequencesOutput 
	
	output:
	stdout into alignmentOutput

	shell:
	"""
	ls -l
//	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/alignment.config
	"""
}
