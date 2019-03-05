echo true

process RunDedupTask {

	output:
	stdout into DedupOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nextflow/Tasks/dedup.nf -c /projects/bioinformatics/PrakruthiWork/NextflowConfig/dedup.config 
	"""
}

