echo true

process testRealignment {

	output:
	stdout into realignmentOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/realignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/realignment.config 
	"""
}

