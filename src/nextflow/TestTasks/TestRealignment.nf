echo true

process RunRealignmentTask {

	output:
	stdout into RealignmentOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/realignment.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/realignment.config 
	"""
}

