//////////////////////////////////////////////////////////////////////////////////////////////

/**       This Nextflow script implements GATK pipeline with Haplotype Caller              **/

/* 				Functions Included			
*	bwa mem 
*	samtools view	
*	samtools sort
*	Picard 
*	targetCreator
*	indelRealigner
*	baseRecalibrator
*	printReads
*	haplotypeCaller      								 */

//////////////////////////////////////////////////////////////////////////////////////////////


// This is the basic genotyping workflow following GATK best practices, using HaplotypeCaller





///////// INITIALIZATION ///////



/// Folders defaults

// output folder to save files in
params.folder = "/projects/bioinformatics/Cynthia_TestData/Nextflow" 
outputDir = file(params.folder) 
outputDir.mkdirs()

// parameter for temporary java workspace
params.tmpJava = "/projects/bioinformatics/Cynthia_TestData/tmp" 
javaDirectory = file(params.tmpJava)



/// Executables

// genome analysis TK parameter
params.GenomeAnalysisTK = "/usr/local/apps/bioapps/gatk/gatk-3.7.0/GenomeAnalysisTK.jar" 



/// Reference defaults

// parameter for reference file
params.fasta_ref = '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa' 
fasta_ref = file(params.fasta_ref)

// find other files associated with reference file
fasta_ref_fai = file(params.fasta_ref+'.fai') 
fasta_ref_sa = file(params.fasta_ref+'.sa')
fasta_ref_bwt = file(params.fasta_ref+'.bwt')
fasta_ref_ann = file(params.fasta_ref+'.ann')
fasta_ref_amb = file(params.fasta_ref+'.amb')
fasta_ref_pac = file(params.fasta_ref+'.pac')
fasta_ref_dict = file(params.fasta_ref.replace(".fa", ".dict"))

// indel reference file
params.indels = "/projects/bioinformatics/Cynthia_TestData/indels/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf" 
knownIndels = file(params.indels) 



/// Inputs

// first read fastq
params.LeftReads = "/projects/bioinformatics/Cynthia_TestData/reads/H3A_NextGen_assessment.Chr1_50X.set5_read1.fq" 
headReads = file(params.LeftReads)

// second read fastq
params.RightReads = "/projects/bioinformatics/Cynthia_TestData/reads/H3A_NextGen_assessment.Chr1_50X.set5_read2.fq" 
tailReads = file(params.LeftReads)

// file containing read name, path for read1, path for read 2 separated by tabs to be entered as input file
params.sampleInfo = ("/projects/bioinformatics/Cynthia_TestData/Nextflow/manyFiles.txt") 

manyFiles = file(params.sampleInfo)





/////// END INITIALIZATION //////////////////









/** create a channel that parses input sample file, reads each line, and splits it by the tab character  **/

inputFiles = Channel
		//define file path to read from
                .fromPath("/projects/bioinformatics/Cynthia_TestData/Nextflow/manyFiles.txt") 
                .splitText() // split by line
                .splitCsv(sep: "\t") //split line by tab character

process alignReads { //perform bwa mem alignment on sample reads

	input:
	//for each name, file read1, file read2 emitted from inputFiles channel
	set val(name), file(read1), file(read2) from inputFiles 	
	file fasta_ref //input reference files
	file fasta_ref_fai
	file fasta_ref_sa
	file fasta_ref_bwt
	file fasta_ref_ann
	file fasta_ref_amb
	file fasta_ref_pac


	// output read name and aligned sam file
	output:
	set val(name), file("${name}.aligned.sam") into alignedFiles 

	"""
	module load /usr/local/apps/bioapps/modules/bwa/bwa-0.7.16

	bwa mem -t 8 -R '@RG\\tID:ga\\tSM:hs\\tLB:ga\\tPL:Illumina\\n@RG\\tID:454\\tSM:hs\\tLB:454\\tPL:454' ${fasta_ref} read1 read2 > ${name}.aligned.sam
	"""
}

process compressFiles { //compress aligned SAM into bam file
	
	input:
	set val(name), file("${name}.aligned.sam") from alignedFiles

	output:
	set val(name), file("${name}.aligned.bam") into compressedFiles

	"""
	/projects/bioinformatics/builds/samtools-1.3.1/bin/samtools view -@ 18 -o ${name}.aligned.bam ${name}.aligned.sam
	""" 
}
 
process sortFile { //sort SAM file using samtools sort

	input:
	set val(name), file("${name}.aligned.bam") from compressedFiles

	output:
	set val(name), file("${name}.sorted.bam") into sortedFiles

	"""
	/projects/bioinformatics/builds/samtools-1.3.1/bin/samtools sort -@ 18 -O bam -o ${name}.sorted.bam -T temp ${name}.aligned.bam
	"""
}

process markDuplicates { //using Picard to mark duplicates in file

	input:
	set val(name), file("${name}.sorted.bam") from sortedFiles

	output:
	set val(name), file("${name}.sorted.marked.bam") into markedFiles
	file '*.bai' into indexFiles
	"""
	module load picard/picard

	java -jar $PICARD MarkDuplicates \
        I=${name}.sorted.bam \
        O=${name}.sorted.marked.bam \
        M=picard_metrics.bam \
	ASSUME_SORTED=true \
	CREATE_INDEX=true
	"""
}

process targetCreator_indelRealigner { //creates realignment targets and realigns the bam file 

	input:
	set val(name), file("${name}.sorted.marked.bam") from markedFiles
	file 'indels' from knownIndels
	file 'tempJava' from javaDirectory
	file fasta_ref
	file fasta_ref_fai
	file fasta_ref_dict

	output:
	set val(name), file("${name}.sorted.marked.realigned.bam") into realignedFiles

	"""
	module load java/java-1.8-64bit
	
	java -Djava.io.tmpdir=tempJava -jar params.GenomeAnalysisTK -R ${fasta_ref} -I ${name}.sorted.marked.bam -T RealignerTargetCreator -nt 18 -known indels -o realignTargetCreator.intervals
	java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -R ${fasta_ref} -I ${name}.sorted.marked.bam -T IndelRealigner -known indels  --targetIntervals realignTargetCreator.intervals -o ${name}.sorted.marked.realigned.bam
	"""
}

process baseRecalibrator_printReads_haplotypeCaller { //recalibrates bases, prints reads, calls variants
	
	input:
	file 'indels' from knownIndels
	set val(name), file("${name}.sorted.marked.realigned.bam") from realignedFiles
	file 'tempJava' from javaDirectory
	file fasta_ref
	file fasta_ref_fai
	file fasta_ref_dict

	output:
	set val(name), file("${name}.sorted.marked.realigned.recalibrated.bam"), file("${name}.sorted.marked.realigned.recalibrated.raw.g.vcf") into recalibratedFiles //final output VCF file

	"""
	module load java/java-1.8-64bit

	java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -T BaseRecalibrator  -R ${fasta_ref} -I ${name}.sorted.marked.realigned.bam -knownSites indels --out recal_report.grp -nct 17
	java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -R ${fasta_ref} -I ${name}.sorted.marked.realigned.bam -T PrintReads -BQSR recal_report.grp --out ${name}.sorted.marked.realigned.recalibrated.bam
	java -Djava.io.tmpdir=tempJava -Xmx16g -jar params.GenomeAnalysisTK -T HaplotypeCaller -R ${fasta_ref} --dbsnp indels -I ${name}.sorted.marked.realigned.recalibrated.bam --emitRefConfidence GVCF -gt_mode DISCOVERY --sample_ploidy 2 -nt 1 -nct 17 -o ${name}.sorted.marked.realigned.recalibrated.raw.g.vcf
	"""
}

recalibratedFiles.subscribe { it.copyTo(outputDir) } //saves final bam and vcf files into output directory
indexFiles.subscribe { it.copyTo(outputDir) } //saves index file into output directory

 

