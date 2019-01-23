echo true

process TrimSequences {	
	
	output:
	trimSequencesOutputFile = Channel.fromPath(params.TrimSequencesOutputDirectory+params.SampleName+"read*.trimmed.fq.gz")
	stdout into trimSequencesOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/trim_sequences.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config  
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
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --TrimmedInputRead1 ${params.TrimSequencesOutputDirectory}"/"${params.SampleName}".read1.trimmed.fq.gz" --TrimmedInputRead2 ${params.TrimSequencesOutputDirectory}"/"${params.SampleName}".read2.trimmed.fq.gz"
	"""
	else if(params.PairedEnd == 'false')
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/alignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --TrimmedInputRead1 ${params.TrimSequencesOutputDirectory}"/"${params.SampleName}".read1.trimmed.fq.gz"  --TrimmedInputRead2 null
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
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/dedup.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --InputAlignedSortedBam ${params.AlignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.bam" --InputAlignedSortedBamBai ${params.AlignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.bam.bai"

        """
}

process Realignment {

	input:
	val preRealignmentFlag from deduplicationOutput

        output:
        stdout into realignmentOutput

        shell:
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/realignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --RefFai ${params.RefFai} --InputAlignedSortedDedupedBam ${params.AlignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.bam" --InputAlignedSortedDedupedBamBai ${params.AlignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.bam.bai"
        """
}

process Bqsr {

        input:
        val preBqsrFlag from realignmentOutput

        output:
        stdout into bqsrOutput

        shell:
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/bqsr.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --InputAlignedSortedDedupedRealignedBam ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam" --InputAlignedSortedDedupedRealignedBamBai ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam.bai"
        """                                                                                                              
}

process Haplotyper {

        input:
        val preHaplotyperFlag from bqsrOutput

        output:
        stdout into haplotyperOutput

        shell:
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/haplotyper.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --InputAlignedSortedDedupedRealignedBam ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam" --InputAlignedSortedDedupedRealignedBamBai ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam.bai" --RecalTable ${params.BQSROutputDirectory}"/"${params.SampleName}".recal_data.table"                                                                                                                       
                                                                                                                         
        """                                                                                                              
}

process Vqsr {

        input:
        val preVqsrFlag from haplotyperOutput                                                                            
                                                                                                                         
        output:                                                                                                          
        stdout into vqsrOutput                                                                                           
                                                                                                                         
        shell:                                                                                                           
        """                                                                                                              
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/vqsr.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/workflow.config --InputVCF ${params.HaplotyperOutputDirectory}"/"${params.SampleName}".vcf" --InputVCFIdx ${params.HaplotyperOutputDirectory}"/"${params.SampleName}".vcf.idx"
        """                                                                                                              
} 
