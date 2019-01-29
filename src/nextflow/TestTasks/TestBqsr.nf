echo true

process RunBqsrTask {

	output:
	stdout into BqsrOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/bqsr.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/bqsr.config 
	"""
}

