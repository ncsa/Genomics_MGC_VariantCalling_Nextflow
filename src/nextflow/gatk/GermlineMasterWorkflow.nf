/******************************************************************************/
/*                                                                            */
/*          This Nextflow script is a Germline workflow for 1 sample          */
/*                                                                            */
/******************************************************************************/

/*******        Nextflow option so bash stdout will be displayed       ********/
echo false

/* ******************        Import input variables          **************** */
SampleName = params.SampleName					 // Sample name used for output
Platform = params.Platform						// Sequencing platform
Library = params.Library	                    // Library name
PlatformUnit = params.PlatformUnit              // Platform unit/ flowcell ID
CenterName = params.CenterName              	// Name of the sequencing center
PairedEnd = params.PairedEnd					// Is input FASTQ paired ended?
Ref = file(params.Ref)                  		// Reference genome
RefAmb = file(params.RefAmb)                    // Reference indices
RefAnn = file(params.RefAnn)                    // Reference indices
RefBwt = file(params.RefBwt)                    // Reference indices
RefPac = file(params.RefPac)                    // Reference indices
RefSa = file(params.RefSa)                      // Reference indices
RefFai = file(params.RefFai)                    // Reference files- implicit
RefDict = file(params.RefDict)                  // to the GATK tool

BqsrKnownSites = params.BqsrKnownSites          // List of known sites+ dbSNP
BqsrKnownSitesChannel = Channel.from(BqsrKnownSites.tokenize(',')).flatMap{ files(it) }.collect()
BqsrKnownSitesIdxChannel = Channel.from(BqsrKnownSites.tokenize(',')).flatMap{ files(it+'.idx') }.collect()
DBSNP = file(params.DBSNP)                  // DBSNP file
DBSNPIdx = file(params.DBSNPIdx)            // Index file for DBSNP file

BWAExe = file(params.BWAExe)                 // Path to BWA executable
ChunkSizeInBases = params.ChunkSizeInBases 	 // 10000000 to normalize threads
BWAExtraOptionsString = params.BWAExtraOptionsString  // BWA extra options

SamtoolsExe = file(params.SamtoolsExe)       // Path to samtools executable
BwaSamtoolsThreads = params.BwaSamtoolsThreads   // Thread required per run

GATKExe = file(params.GATKExe)                  // GATK executable path
ApplyBQSRExtraOptionsString = params.ApplyBQSRExtraOptionsString
HaplotyperThreads = params.HaplotyperThreads
HaplotyperExtraOptionsString = params.HaplotyperExtraOptionsString
JavaExe = file(params.JavaExe)                  // Java executable path
JavaOptionsString = params.JavaOptionsString    //String of java vm options

BashPreamble = file(params.BashPreamble)        // For zombie processes
BashSharedFunctions = file(params.BashSharedFunctions)	// For variable checks
DebugMode = params.DebugMode					// Flag to enable debug mode

AlignmentScript = file(params.AlignmentScript)	// script running alignment
MergeBamScript = params.MergeBamScript			// script running merge BAMs
DedupScript = file(params.DedupScript)          // script running deduplication
BqsrScript = file(params.BqsrScript)            // script of the bqsr job
HaplotyperScript = file(params.HaplotyperScript) // script of GATK code
MergeGvcfsScript = file(params.MergeGvcfsScript) // script of GATK code


AlignmentMultinode = params.AlignmentMultinode

DeliveryFolder_Alignment = params.DeliveryFolder_Alignment
DeliveryFolder_HaplotyperVC = params.DeliveryFolder_HaplotyperVC


/******************************************************************************/
/*                                                                            */
/*      The following are process definitions and their channels wiring!      */
/*                                                                            */
/******************************************************************************/


/* *********      Alignment: per lane (of a sample) - Required   ************ */
InputRead1 = params.InputRead1                              // Input Read File
InputRead2 = params.InputRead2                               // Input Read File
InputRead1Channel = Channel.fromPath(InputRead1.tokenize(','))

InputRead2Channel = ( PairedEnd == 'true'
                      ? Channel.fromPath(InputRead2.tokenize(','))
                      : file('null').fileName )

PlatformUnitChannel = Channel.from(PlatformUnit.tokenize(','))

process Alignment{

    publishDir DeliveryFolder_Alignment, mode: 'copy'

	input:
    	val SampleName
    	val Platform
        val Library
        val PlatformUnit from PlatformUnitChannel
        val CenterName
    	val PairedEnd
    	file InputRead1 from InputRead1Channel
    	file InputRead2 from InputRead2Channel
    	file Ref
    	file RefAmb
    	file RefAnn
    	file RefBwt
    	file RefPac
    	file RefSa
        file BWAExe
    	val ChunkSizeInBases
        val BWAExtraOptionsString
        file SamtoolsExe
    	val BwaSamtoolsThreads
        file BashSharedFunctions
     	val DebugMode

        file BashPreamble
    	file AlignmentScript

    output:
        file "${SampleName}.${PlatformUnit}.bam" into AlignOutputBams
        file "${SampleName}.${PlatformUnit}.bam.bai" into AlignOutputBais

    script:
       	"""
        source ${BashPreamble}
        /bin/bash ${AlignmentScript} -s ${SampleName} -p ${Platform} \
            -L ${Library} -f ${PlatformUnit} -c ${CenterName} -P ${PairedEnd} \
            -l ${InputRead1} -r ${InputRead2} -G ${Ref} -e ${BWAExe} \
            -K ${ChunkSizeInBases} -o \"\'${BWAExtraOptionsString}\'\" \
            -S ${SamtoolsExe} -t ${BwaSamtoolsThreads} -F ${BashSharedFunctions}\
            ${DebugMode}
        """
}

/* ***********    Merge: all lanes (of a sample) - Required      ************ */

process MergeBams {
    publishDir DeliveryFolder_Alignment, mode: 'copy'

	input:
        file InputBam from AlignOutputBams.collect()    // Link to Alignment
        file InputBai from AlignOutputBais.collect()    // Link to Alignment

    output:
        file "${SampleName}.bam" into MergeOutputBams
        file "${SampleName}.bam.bai" into MergeOutputBais

		"""
        source ${BashPreamble}
		/bin/bash ${MergeBamScript} -b ${InputBam.join(',')} -s ${SampleName} \
            -S ${SamtoolsExe} \
            -F ${BashSharedFunctions} ${DebugMode}
		"""
}

/*****************         Dedup: per sample - Optional           *************/
process Deduplication{
   input:
       val SampleName

       file InputBams from  MergeOutputBams // Link to MergeBams
       file InputBais from MergeOutputBais  // Link to MergeBams

       file GATKExe
       file JavaExe
       val JavaOptionsString

       val DebugMode

       file BashPreamble
       file BashSharedFunctions

       file DedupScript

   output:
       file "${SampleName}.bam" into DedupOutputBams
       file "${SampleName}.bam.bai" into DedupOutputBais

   when:
       params.MarkDuplicates == 'true'

   script:
       """
       source ${BashPreamble}
       /bin/bash ${DedupScript} -s ${SampleName} -b ${InputBams} -S ${GATKExe} \
            -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" \
            -F ${BashSharedFunctions} {DebugMode}
       """
}

/*********       BQSR: per interval (of a sample) - Required        ***********/

Channel                                         // Chromosome names/intervals
    .from(params.GenomicIntervals.tokenize(','))
    .into{BqsrGenomicIntervals; HcGenomicIntervals}

BQSRInputBams = (params.MarkDuplicates == 'true' // Link MergeBams or
                ? DedupOutputBams : MergeOutputBams) // Deduplication
BQSRInputBais = (params.MarkDuplicates == 'true'
                ? DedupOutputBais : MergeOutputBais)

process BQSR{

   publishDir DeliveryFolder_Alignment, mode: 'copy'

   input:
        val SampleName
    	file InputBams from BQSRInputBams
	    file InputBais from BQSRInputBais

    	file Ref
      	file RefFai
        file RefDict

    	file BqsrKnownSites from BqsrKnownSitesChannel
    	file BqsrKnownSitesIdx from BqsrKnownSitesIdxChannel

        val GenomicInterval from BqsrGenomicIntervals
        file GATKExe
        val ApplyBQSRExtraOptionsString
        file JavaExe
        val JavaOptionsString

        file BashPreamble
        file BashSharedFunctions
        file BqsrScript

   output:
        file "${SampleName}.${GenomicInterval}.bam" into BqsrOutputBams
        file "${SampleName}.${GenomicInterval}.bai" into BqsrOutputBais

   script:
       """
        source ${BashPreamble}
       /bin/bash ${BqsrScript} -s ${SampleName} -b ${InputBams} -G ${Ref} \
         -k ${BqsrKnownSites.join(',')} -I ${GenomicInterval} -S ${GATKExe} \
         -o \"\'${ApplyBQSRExtraOptionsString}\'\" -J ${JavaExe} \
         -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions} ${DebugMode}
       """
}

/********      haplotyper: per interval (of a sample) - Required      *********/

process Haplotyper{

   publishDir DeliveryFolder_HaplotyperVC, mode: 'copy'

   input:
    	val SampleName

    	file InputBams from BqsrOutputBams // Link to BQSR
	    file InputBais from BqsrOutputBais // Link to BQSR
    	file Ref
	    file RefFai
        file RefDict

    	file DBSNP
	    file DBSNPIdx
	    val GenomicInterval from HcGenomicIntervals

        file GATKExe
        val HaplotyperThreads
        val HaplotyperExtraOptionsString
        file JavaExe
        val JavaOptionsString

        file BashPreamble
        file BashSharedFunctions
        file HaplotyperScript

	    val DebugMode

   output:
        file "${SampleName}.${GenomicInterval}.g.vcf" into HcOutputVcf
        file "${SampleName}.${GenomicInterval}.g.vcf.idx" into HcOutputVcfIdx

   script:
       """
       source ${BashPreamble}
       /bin/bash ${HaplotyperScript} -s ${SampleName} -b ${InputBams} -G ${Ref} \
            -D ${DBSNP} -I ${GenomicInterval} -S ${GATKExe} \
            -t ${HaplotyperThreads} -o \"\'${HaplotyperExtraOptionsString}\'\" \
            -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" -F ${BashSharedFunctions}\
             ${DebugMode}
       """
}

/********      Merge Gvcfs: all intervals (of a sample) - Required    *********/

process Mergegvcfs {

   publishDir DeliveryFolder_HaplotyperVC, mode: 'copy'

   input:
    	val SampleName

        file InputGvcfs from HcOutputVcf.collect()  // Link to Haplotyper
        file InputIdxs from HcOutputVcfIdx.collect()  //Link to Haplotyper

        file GATKExe
        file JavaExe
        val JavaOptionsString

        file BashPreamble
        file BashSharedFunctions
        file MergeGvcfsScript

	    val DebugMode

   output:
        file "${SampleName}.g.vcf" into OutputVcf
        file "${SampleName}.g.vcf.idx" into OutputVcfIdx

   script:
       """
       source ${BashPreamble}
       /bin/bash ${MergeGvcfsScript} -s ${SampleName} -b ${InputGvcfs.join(',')} \
        -S ${GATKExe} -J ${JavaExe} -e \"\'${JavaOptionsString}\'\" \
        -F ${BashSharedFunctions} ${DebugMode}
       """
}
