echo true

nextflowRunFolder = "/projects/bioinformatics/PrakruthiWork/NextflowRuns"

process TrimSequences {	
	
	output:
	trimSequencesOutputFile = Channel.fromPath(nextflowRunFolder+"*trimmed.*")
	stdout into trimSequencesOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/trim_sequences.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db1.config  
	"""
}

process Alignment {

	input:
	val preAlignmentFlag from trimSequencesOutput 
	
	output:
	stdout into alignmentOutput

	shell:
	"""
	ls -l
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db1.config
	"""
}

process Deduplication {

        input:
        val preDeduplicationFlag from alignmentOutput

        output:
        stdout into deduplicationOutput

        shell:
        """
        ls -l
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/dedup.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db1.config
        """
}

