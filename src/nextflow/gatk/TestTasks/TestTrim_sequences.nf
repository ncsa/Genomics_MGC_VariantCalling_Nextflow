echo true

process RunTrim_sequencesTask {

	output:
	stdout into Trim_sequencesOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/trim_sequences.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/trim_sequences.config 
	"""
}

