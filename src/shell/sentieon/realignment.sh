#!/bin/bash

#-------------------------------------------------------------------------------------------------------------------------------
## realignment.sh MANIFEST, USAGE DOCS, SET CHECKS
#-------------------------------------------------------------------------------------------------------------------------------

read -r -d '' MANIFEST << MANIFEST

*****************************************************************************
`readlink -m $0`
called by: `whoami` on `date`
command line input: ${@}
*****************************************************************************

MANIFEST
echo -e "\n${MANIFEST}"







read -r -d '' DOCS << DOCS

#############################################################################
#
# Realign reads using Sentieon Realigner. Part of the MayomicsVC Workflow.
# 
#############################################################################

 USAGE:
 realignment.sh    -s           <sample_name> 
                   -b           <sorted.deduped.bam>
                   -G		<reference_genome>
                   -k		<known_sites> (omni.vcf, hapmap.vcf, indels.vcf, dbSNP.vcf) 
                   -S           </path/to/sentieon> 
                   -t           <threads> 
                   -e           </path/to/env_profile_file>
		   -O 		</path/to/output/directory>
                   -d           turn on debug mode

 EXAMPLES:
 realignment.sh -h
 realignment.sh -s sample -b sorted.deduped.bam -G reference.fa -k known1.vcf,known2.vcf,...knownN.vcf -S /path/to/sentieon_directory -t 12 -e /path/to/env_profile_file -O /path/to/output_directory -d

#############################################################################

DOCS









set -o errexit
set -o pipefail
set -o nounset

SCRIPT_NAME=realignment.sh
SGE_JOB_ID=TBD  # placeholder until we parse job ID
SGE_TASK_ID=TBD  # placeholder until we parse task ID

#-------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------
## LOGGING FUNCTIONS
#-------------------------------------------------------------------------------------------------------------------------------

# Get date and time information
function getDate()
{
    echo "$(date +%Y-%m-%d'T'%H:%M:%S%z)"
}

# This is "private" function called by the other logging functions, don't call it directly,
# use logError, logWarn, etc.
function _logMsg () {
    echo -e "${1}"

    if [[ -n ${ERRLOG-x} ]]; then
        echo -e "${1}" | sed -r 's/\\n//'  >> "${ERRLOG}"
    fi
}

function logError()
{
    local LEVEL="ERROR"
    local CODE="-1"

    if [[ ! -z ${2+x} ]]; then
        CODE="${2}"
    fi

    >&2 _logMsg "[$(getDate)] ["${LEVEL}"] [${SCRIPT_NAME}] [${SGE_JOB_ID-NOJOB}] [${SGE_TASK_ID-NOTASK}] [${CODE}] \t${1}"

    if [[ -z ${EXITCODE+x} ]]; then
        EXITCODE=1
    fi

    exit ${EXITCODE};
}

function logWarn()
{
    local LEVEL="WARN"
    local CODE="0"

    if [[ ! -z ${2+x} ]]; then
        CODE="${2}"
    fi

    _logMsg "[$(getDate)] ["${LEVEL}"] [${SCRIPT_NAME}] [${SGE_JOB_ID-NOJOB}] [${SGE_TASK_ID-NOTASK}] [${CODE}] \t${1}"
}

function logInfo()
{
    local LEVEL="INFO"
    local CODE="0"

    if [[ ! -z ${2+x} ]]; then
        CODE="${2}"
    fi

    _logMsg "[$(getDate)] ["${LEVEL}"] [${SCRIPT_NAME}] [${SGE_JOB_ID-NOJOB}] [${SGE_TASK_ID-NOTASK}] [${CODE}] \t${1}"
}

function checkArg()
{
    if [[ "${OPTARG}" == -* ]]; then
        echo -e "\nError with option -${OPT} in command. Option passed incorrectly or without argument.\n"
        echo -e "\n${DOCS}\n"
        exit 1;
    fi
}

#-------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------
## GETOPTS ARGUMENT PARSER
#-------------------------------------------------------------------------------------------------------------------------------

## Check if no arguments were passed
if (($# == 0))
then
        echo -e "\nNo arguments passed.\n\n${DOCS}\n"
        exit 1
fi

## Input and Output parameters
while getopts ":hs:b:G:k:S:t:e:O:d" OPT
do
        case ${OPT} in
                h )  # Flag to display usage
                        echo -e "\n${DOCS}\n"
                        exit 0
			;;
                s )  # Sample name
                        SAMPLE=${OPTARG}
			checkArg
                        ;;
		b )  # Full path to the input deduped BAM
			INPUTBAM=${OPTARG}
			checkArg
			;;
                G )  # Full path to reference genome fasta file
                        REFGEN=${OPTARG}
			checkArg
                        ;;
		k )  # Full path to known sites files
			KNOWN=${OPTARG}
			checkArg
			;;
                S )  # Full path to sentieon directory
                        SENTIEON=${OPTARG}
			checkArg
                        ;;
                t )  # Number of threads available
                        THR=${OPTARG}
			checkArg
                        ;;
                e )  # Path to file with environmental profile variables
                        ENV_PROFILE=${OPTARG}
                        checkArg
                        ;;
		O )  # Path to output directory
                        OUTPUT_DIRECTORY=${OPTARG}
                        checkArg
                        ;;

                d )  # Turn on debug mode. Initiates 'set -x' to print all text. Invoked with -d
			echo -e "\nDebug mode is ON.\n"
			set -x
                        ;;
		\? )  # Check for unsupported flag, print usage and exit.
                        echo -e "\nInvalid option: -${OPTARG}\n\n${DOCS}\n"
                        exit 1
                        ;;
		: )  # Check for missing arguments, print usage and exit.
                        echo -e "\nOption -${OPTARG} requires an argument.\n\n${DOCS}\n"
                        exit 1
                        ;;
        esac
done

#-------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------
## PRECHECK FOR INPUTS AND OPTIONS
#-------------------------------------------------------------------------------------------------------------------------------

## Check if Sample Name variable exists
if [[ -z ${SAMPLE+x} ]] ## NOTE: ${VAR+x} is used for variable expansions, preventing unset variable error from set -o nounset. When $VAR is not set, we set it to "x" and throw the error.
then
        echo -e "$0 stopped at line ${LINENO}. \nREASON=Missing sample name option: -s"
        exit 1
fi

## Create log for JOB_ID/script
ERRLOG=${SAMPLE}.realignment.${SGE_JOB_ID}.log
truncate -s 0 "${ERRLOG}"
truncate -s 0 ${SAMPLE}.realign_sentieon.log

## Write manifest to log
echo "${MANIFEST}" >> "${ERRLOG}"

## source the file with environmental profile variables
if [[ ! -z ${ENV_PROFILE+x} ]]
then
        source ${ENV_PROFILE}
else
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Missing environmental profile option: -e"
fi

## Check if input files, directories, and variables are non-zero
if [[ -z ${INPUTBAM+x} ]]
then
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Missing input deduplicated BAM option: -b"
fi
if [[ ! -s ${INPUTBAM} ]]
then
	EXITCODE=1
	logError "$0 stopped at line ${LINENO}. \nREASON=Deduped BAM ${INPUTBAM} is empty or does not exist."
fi
if [[ ! -s ${INPUTBAM}.bai ]]
then
	EXITCODE=1
       logError "$0 stopped at line ${LINENO}. \nREASON=Deduped BAM index ${INPUTBAM}.bai is empty or does not exist."
fi
if [[ -z ${REFGEN+x} ]]
then
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Missing reference genome option: -G"
fi
if [[ ! -s ${REFGEN} ]]
then
	EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Reference genome file ${REFGEN} is empty or does not exist."
fi
if [[ -z ${OUTPUT_DIRECTORY} ]]
then
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Missing output directory option: -D"
fi
if [[ ! -d ${OUTPUT_DIRECTORY} ]]
then
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON= ${OUTPUT_DIRECTORY} does not exist or is not a directory."
fi
if [[ -z ${KNOWN+x} ]]
then
	EXITCODE=1
	logError "$0 stopped at line ${LINENO}. \nREASON=Missing known sites option ${KNOWN}: -k"
fi
if [[ -z ${SENTIEON+x} ]]
then
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Missing Sentieon path option: -S"
fi
if [[ ! -d ${SENTIEON} ]]
then
	EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Sentieon directory ${SENTIEON} is not a directory or does not exist."
fi
if [[ -z ${THR+x} ]]
then
        EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Missing threads option: -t"
fi

#-------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------
## FILENAME AND OPTION PARSING
#-------------------------------------------------------------------------------------------------------------------------------

## Parse known sites list of multiple files. Create multiple -k flags for sentieon
SPLITKNOWN=`sed -e 's/,/ -k /g' <<< ${KNOWN}`
echo ${SPLITKNOWN}

## Parse filenames without full path
OUT=${SAMPLE}.aligned.sorted.deduped.realigned.bam

#-------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------
## REALIGNMENT STAGE
#-------------------------------------------------------------------------------------------------------------------------------

## Record start time
logInfo "[Realigner] START. Realigning deduped BAM. Using known sites at ${KNOWN} ."

## Sentieon Realigner command.
TRAP_LINE=$(($LINENO + 1))
trap 'logError " $0 stopped at line ${TRAP_LINE}. Sentieon Realignment error. " ' INT TERM EXIT
${SENTIEON}/bin/sentieon driver -t ${THR} -r ${REFGEN} -i ${INPUTBAM} --algo Realigner -k ${SPLITKNOWN} ${OUTPUT_DIRECTORY}/${OUT} >> ${SAMPLE}.realign_sentieon.log 2>&1
EXITCODE=$?
trap - INT TERM EXIT

if [[ ${EXITCODE} -ne 0 ]]
then
        logError "$0 stopped at line ${LINENO} with exit code ${EXITCODE}."
fi
logInfo "[Realigner] Realigned reads ${SAMPLE} to reference ${REFGEN}. Realigned BAM located at ${OUT}."

#-------------------------------------------------------------------------------------------------------------------------------





#-------------------------------------------------------------------------------------------------------------------------------
## POST-PROCESSING
#-------------------------------------------------------------------------------------------------------------------------------

## Check for creation of realigned BAM and index. Open read permissions to the user group
if [[ ! -s ${OUTPUT_DIRECTORY}/${OUT} ]]
then
	EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Realigned BAM ${OUT} is empty."
fi
if [[ ! -s ${OUTPUT_DIRECTORY}/${OUT}.bai ]]
then
	EXITCODE=1
        logError "$0 stopped at line ${LINENO}. \nREASON=Realigned BAM ${OUT}.bai is empty."
fi
chmod g+r ${OUTPUT_DIRECTORY}/${OUT}
chmod g+r ${OUTPUT_DIRECTORY}/${OUT}.bai
#-------------------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------
## END
#-------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------
exit 0;
