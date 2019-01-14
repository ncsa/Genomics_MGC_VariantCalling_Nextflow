echo true

process testAlignment {

	output:
	stdout into alignmentOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/nf_alignment.config 
	"""
}

