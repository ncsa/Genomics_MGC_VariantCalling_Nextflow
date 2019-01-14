echo true

process testVqsr {

	output:
	stdout into vqsrOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/vqsr.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/vqsr.config 
	"""
}

