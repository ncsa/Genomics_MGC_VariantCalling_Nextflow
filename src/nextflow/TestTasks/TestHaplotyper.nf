echo true

process RunHaplotyperTask {

	output:
	stdout into HaplotyperOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/haplotyper.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/haplotyper.config 
	"""
}

