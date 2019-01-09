echo true

process testDeduplication {

	output:
	stdout into deduplicationOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/dedup.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/dedup.config 
	"""
}

