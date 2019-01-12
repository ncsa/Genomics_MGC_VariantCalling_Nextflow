echo true

process TrimSequences {	
	
	output:
	trimSequencesOutputFile = Channel.fromPath(params.TrimSequencesOutputDirectory+params.SampleName+"read*.trimmed.fq.gz")
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

	script:
	if(params.PairedEnd == 'true')
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db1.config --TrimmedInputRead1 ${params.TrimSequencesOutputDirectory}"/"${params.SampleName}".read1.trimmed.fq.gz" --TrimmedInputRead2 ${params.TrimSequencesOutputDirectory}"/"${params.SampleName}".read2.trimmed.fq.gz"
	"""
	else if(params.PairedEnd == 'false')
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db1.config --TrimmedInputRead1 ${params.TrimSequencesOutputDirectory}"/"${params.SampleName}".read1.trimmed.fq.gz"  --TrimmedInputRead2 null
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
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/dedup.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db1.config --InputAlignedSortedBam ${params.AlignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.bam" --InputAlignedSortedBamBai ${params.AlignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.bam.bai"

        """
}

