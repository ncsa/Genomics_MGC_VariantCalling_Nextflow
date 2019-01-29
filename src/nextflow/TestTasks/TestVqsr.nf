echo true

process RunVqsrTask {

	output:
	stdout into VqsrOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/vqsr.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/vqsr.config 
	"""
}

