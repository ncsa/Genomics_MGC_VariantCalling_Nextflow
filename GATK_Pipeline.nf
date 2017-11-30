params.folder = "/projects/bioinformatics/Cynthia_TestData/Nextflow"
outputDir = file(params.folder)
outputDir.mkdirs()

params.fasta_ref = '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa'
fasta_ref = file(params.fasta_ref)

/**
params.fasta_ref_fai =  '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa.fai'
fasta_ref_fai = file(params.fasta_ref_fai)
params.fasta_ref_sa =  '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa.sa'
fasta_ref_sa = file(params.fasta_ref_sa)
params.fasta_ref_bwt = '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa.bwt'
fasta_ref_bwt = file(params.fasta_ref_bwt)
params.fasta_ref_ann =  '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa.ann'
fasta_ref_ann = file(params.fasta_ref_ann)
params.fasta_ref_amb =  '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa.amb'
fasta_ref_amb = file(params.fasta_ref_amb)
params.fasta_ref_pac =  '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.fa.pac'
fasta_ref_pac = file(params.fasta_ref_pac)
params.fasta_ref_dict =  '/projects/bioinformatics/Cynthia_TestData/reference/ref.chr1.simple_naming.dict'
fasta_ref_dict = file(params.fasta_ref_dict)
**/

fasta_ref_fai = file(params.fasta_ref+'.fai')
fasta_ref_sa = file(params.fasta_ref+'.sa')
fasta_ref_bwt = file(params.fasta_ref+'.bwt')
fasta_ref_ann = file(params.fasta_ref+'.ann')
fasta_ref_amb = file(params.fasta_ref+'.amb')
fasta_ref_pac = file(params.fasta_ref+'.pac')
fasta_ref_dict = file(params.fasta_ref.replace(".fa", ".dict"))

params.head = "/projects/bioinformatics/Cynthia_TestData/reads/H3A_NextGen_assessment.Chr1_50X.set5_read1.fq"
headReads = file(params.head)

params.tail = "/projects/bioinformatics/Cynthia_TestData/reads/H3A_NextGen_assessment.Chr1_50X.set5_read2.fq"
tailReads = file(params.tail)

params.indels = "/projects/bioinformatics/Cynthia_TestData/indels/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf"
knownIndels = file(params.indels)

params.tmpJava = "/projects/bioinformatics/Cynthia_TestData/tmp"
javaDirectory = file(params.tmpJava)

params.GenomeAnalysisTK = "/usr/local/apps/bioapps/gatk/gatk-3.7.0/GenomeAnalysisTK.jar"

params.sampleInfo = ("/projects/bioinformatics/Cynthia_TestData/Nextflow/manyFiles.txt")
manyFiles = file(params.sampleInfo)

inputFiles = Channel
                .from(manyFiles)
                .splitCsv(sep:"\t")
                .buffer(size:3)

process alignReads {

        input:
/**     set name, 'read1', 'read2' from inputFiles **/
        file read1 from headReads
        file read2 from tailReads
        file fasta_ref
        file fasta_ref_fai
        file fasta_ref_sa
        file fasta_ref_bwt
        file fasta_ref_ann
        file fasta_ref_amb
        file fasta_ref_pac

        output:
        file 'ALIGNME' into alignedFiles

        """
        module load /usr/local/apps/bioapps/modules/bwa/bwa-0.7.16

        bwa mem -t 8 -R '@RG\\tID:ga\\tSM:hs\\tLB:ga\\tPL:Illumina\\n@RG\\tID:454\\tSM:hs\\tLB:454\\tPL:454' ${fasta_ref} read1 read2 > ALIGNME
        """
}
/*
 | /projects/bioinformatics/builds/samtools-1.3.1/bin/samtools view -@ 18 -o compressed.bam
        """
*/

process compressFiles {

        input:
        file 'ALIGNME' from alignedFiles

        output:
        file 'IMCOMPRESSED.bam' into compressedFiles

        """
        /projects/bioinformatics/builds/samtools-1.3.1/bin/samtools view -@ 18 -o IMCOMPRESSED.bam ALIGNME
        """
}

process sortFile {

        input:
        file 'IMCOMPRESSED.bam' from compressedFiles

        output:
        file 'IMSORTEDOUT.bam' into sortedFiles

        """
        /projects/bioinformatics/builds/samtools-1.3.1/bin/samtools sort -@ 18 -O bam -o IMSORTEDOUT.bam -T temp IMCOMPRESSED.bam

        """
}

process markDuplicates {

        input:
        file 'IMSORTEDOUT.bam' from sortedFiles

        output:
        file 'IVEBEENMARKED.bam' into markedFiles
        file '*.bai' into indexFiles
        """
        module load picard/picard

        java -jar $PICARD MarkDuplicates \
        I=IMSORTEDOUT.bam \
        O=IVEBEENMARKED.bam \
        M=picard_metrics.bam \
        ASSUME_SORTED=true \
        CREATE_INDEX=true
        """
}

process targetCreator {

        input:
        file 'IVEBEENMARKED.bam' from markedFiles
        file 'indels' from knownIndels
        file 'tempJava' from javaDirectory
        file fasta_ref
        file fasta_ref_fai
        file fasta_ref_dict

        output:
        file 'ivebeenSorted.Marked.Realigned.bam' into realignedFiles

        """
        module load java/java-1.8-64bit

        java -Djava.io.tmpdir=tempJava -jar params.GenomeAnalysisTK -R ${fasta_ref} -I IVEBEENMARKED.bam -T RealignerTargetCreator -nt 18 -known indels -o realignTargetCreator.intervals
        java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -R ${fasta_ref} -I IVEBEENMARKED.bam -T IndelRealigner -known indels  --targetIntervals realignTargetCreator.intervals -o ivebeenSorted.Marked.Realigned.bam
        """
}

/**
process indelRealigner {

        input:
        file 'IVEBEENMARKED.bam' from markedFiles
        file 'indels' from knownIndels
        file 'targetCreator.intervals' from targetsCreated
        file 'tempJava' from javaDirectory
        file fasta_ref
        file fasta_ref_fai
        file fasta_ref_dict

        output:
        file 'ivebeenSorted.Marked.Realigned.bam' into realignedFiles

        """
        module load java/java-1.8-64bit

        java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -R ${fasta_ref} -I IVEBEENMARKED.bam -T IndelRealigner -known indels  --targetIntervals targetCreator.intervals -o ivebeenSorted.Marked.Realigned.bam
        """
}
**/

process baseRecalibrator {

        input:
        file 'indels' from knownIndels
        file 'ivebeenSorted.Marked.Realigned.bam' from realignedFiles
        file 'tempJava' from javaDirectory
        file fasta_ref
        file fasta_ref_fai
        file fasta_ref_dict

        output:
        file 'recal_report.grp' into recalReports

        """
        module load java/java-1.8-64bit

        java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -T BaseRecalibrator  -R ${fasta_ref} -I ivebeenSorted.Marked.Realigned.bam -knownSites indels --out recal_report.grp -nct 17
        """
}

process printReads {

        input:
        file 'recal_report.grp' from recalReports
        file 'tempJava' from javaDirectory
        file 'ivebeenSorted.Marked.Realigned.bam' from realignedFiles
        file fasta_ref
        file fasta_ref_fai
        file fasta_ref_dict

        output:
        file 'IVEBEENRECALIBRATED1.bam' into recalibratedFiles

        """
        module load java/java-1.8-64bit

        java -Djava.io.tmpdir=tempJava -Xmx8g -jar params.GenomeAnalysisTK -R ${fasta_ref} -I ivebeenSorted.Marked.Realigned.bam -T PrintReads -BQSR recal_report.grp --out IVEBEENRECALIBRATED1.bam
        """
}

process haplotypeCaller {

        input:
        file 'indels' from knownIndels
        file 'IVEBEENRECALIBRATED1.bam' from recalibratedFiles
        file 'tempJava' from javaDirectory
        file fasta_ref
        file fasta_ref_fai
        file fasta_ref_dict

        output:
        file 'IVEBEENRECALIBRATED1.raw.g.vcf' into finalFiles

        """
        module load java/java-1.8-64bit

        java -Djava.io.tmpdir=tempJava -Xmx16g -jar params.GenomeAnalysisTK -T HaplotypeCaller -R ${fasta_ref} --dbsnp indels -I IVEBEENRECALIBRATED1.bam --emitRefConfidence GVCF -gt_mode DISCOVERY --sample_ploidy 2 -nt 1 -nct 17 -o IVEBEENRECALIBRATED1.raw.g.vcf
        """
}

recalibratedFiles.subscribe { it.copyTo(outputDir) }
targetsCreated.subscribe { it.copyTo(outputDir) }
realignedFiles.subscribe { it.copyTo(outputDir) }
indexFiles.subscribe { it.copyTo(outputDir) }
recalReports.subscribe {it.copyTo(outputDir) }
finalFiles.subscribe {it.copyTo(outputDir) }



