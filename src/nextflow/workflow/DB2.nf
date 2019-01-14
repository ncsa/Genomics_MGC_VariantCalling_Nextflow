echo true

process Realignment {	
	
	output:
	stdout into realignmentOutput	

	shell:
	"""
	nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/realignment.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db2.config  
	"""
}

process Bqsr {
	
	input:
	val preBqsrFlag from realignmentOutput

        output:
        stdout into bqsrOutput

        shell:
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/bqsr.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db2.config --InputAlignedSortedDedupedRealignedBam ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam" --InputAlignedSortedDedupedRealignedBamBai ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam.bai"
        """
}

process Haplotyper {

	input:
	val preHaplotyperFlag from bqsrOutput

	output:
	stdout into haplotyperOutput

	shell:
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/haplotyper.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db2.config --InputAlignedSortedDedupedRealignedBam ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam" --InputAlignedSortedDedupedRealignedBamBai ${params.RealignmentOutputDirectory}"/"${params.SampleName}".aligned.sorted.deduped.realigned.bam.bai" --RecalTable ${params.BQSROutputDirectory}"/"${params.SampleName}".recal_data.table"

	"""
}

process Vqsr {

	input:
	val preVqsrFlag from haplotyperOutput

        output:
        stdout into vqsrOutput

        shell:
        """
        nextflow run /projects/bioinformatics/PrakruthiWork/Genomics_MGC_VariantCalling_Nextflow/src/nf_scripts/vqsr.nf -c /projects/bioinformatics/PrakruthiWork/nf_config/db2.config --InputVCF ${params.HaplotyperOutputDirectory}"/"${params.SampleName}".vcf" --InputVCFIdx ${params.HaplotyperOutputDirectory}"/"${params.SampleName}".vcf.idx"
        """
}

