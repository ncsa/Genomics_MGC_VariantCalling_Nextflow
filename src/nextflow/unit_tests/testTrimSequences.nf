echo true

process testTrimSequences {

	output:
	stdout into trimSequencesOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/trim_sequences.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/trim_sequences.config 
	"""
}

