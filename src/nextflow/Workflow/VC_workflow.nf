echo true

process TrimSequences {	
	
	output:
	stdout into trimSequencesOutput	

	script:
	"""
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/trim_sequences.nf -c ${params.ConfigsDir}/VC_workflow.config  
	"""
}


process Alignment {

	input:
	val preAlignmentFlag from trimSequencesOutput 	
		
	output:
	stdout into alignmentOutput

	script:
	"""
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/alignment.nf -c ${params.ConfigsDir}/VC_workflow.config
	"""
}

process Merge {
	input:
	val preMergingFlag from alignmentOutput

	output:
	stdout into mergeOutput

	script:
	"""
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/merge.nf -c ${params.ConfigsDir}/VC_workflow.config
	"""
}

process Deduplication {

        input:
        val preDeduplicationFlag from mergeOutput

        output:
        stdout into deduplicationOutput

	script:
        """
        ${params.NextflowExecutable} run ${params.NextflowScriptsDir}/dedup.nf -c ${params.ConfigsDir}/VC_workflow.config 
        """
}

process Realignment {

	input:
	val preRealignmentFlag from deduplicationOutput
 
        output:
        stdout into realignmentOutput

        script:
        """
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/realignment.nf -c ${params.ConfigsDir}/VC_workflow.config
        """
}

process Bqsr {

        input:
        val preBqsrFlag from realignmentOutput

        output:
        stdout into bqsrOutput

        script:
        """
        ${params.NextflowExecutable} run ${params.NextflowScriptsDir}/bqsr.nf -c ${params.ConfigsDir}/VC_workflow.config
        """
}

process Haplotyper {

        input:
        val preHaplotyperFlag from bqsrOutput

        output:
        stdout into haplotyperOutput

        script:
        """
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/haplotyper.nf -c ${params.ConfigsDir}/VC_workflow.config
        """
}

process Vqsr {

        input:
        val preVqsrFlag from haplotyperOutput

        output:
        stdout into vqsrOutput

        script:
        """
	${params.NextflowExecutable} run ${params.NextflowScriptsDir}/vqsr.nf -c ${params.ConfigsDir}/VC_workflow.config
        """
}

