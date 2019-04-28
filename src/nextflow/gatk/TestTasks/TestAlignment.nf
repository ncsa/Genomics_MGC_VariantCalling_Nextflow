echo true

process RunAlignmentTask {

	output:
	stdout into AlignmentOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/alignment.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/alignment.config 
	"""
}

