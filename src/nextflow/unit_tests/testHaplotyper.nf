echo true

process testHaplotyper {

	output:
	stdout into haplotyperOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/haplotyper.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/haplotyper.config 
	"""
}

