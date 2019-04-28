echo true

process TrimSequences {	
	
	output:
	stdout into trimSequencesOutput	

	script:
	"""
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/trim_sequences.nf -c ${params.ConfigsDir}/design_block1.config  
	"""
}


process Alignment {

	input:
	val preAlignmentFlag from trimSequencesOutput 	
		
	output:
	stdout into alignmentOutput

	script:
	"""
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/alignment.nf -c ${params.ConfigsDir}/design_block1.config
	"""
}

process Merge {
	input:
	val preMergingFlag from alignmentOutput

	output:
	stdout into mergeOutput

	script:
	"""
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/merge.nf -c ${params.ConfigsDir}/design_block1.config
	"""
}

process Deduplication {

        input:
        val preDuplicationFlag from mergeOutput

        output:
        stdout into deduplicationOutput

	script:
        """
        ${params.NextflowExecutable} run ${params.NextflowScriptsDir}/dedup.nf -c ${params.ConfigsDir}/design_block1.config 
        """
}

