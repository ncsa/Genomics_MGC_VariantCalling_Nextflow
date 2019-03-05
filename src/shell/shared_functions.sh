#!/bin/bash


#########################################################
#
#  Logging functions used in MayomicsVC bash scripts
#
#########################################################


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
    echo "exitcode=${EXITCODE}";
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






##################################################################
#
# Functions to check for set variables and files 
#
##################################################################

# we need to figure out a good way to produce error messages, 
# I think we should pass in a REASON string to argument $2, that's how I setting up the script for now.
## NOTE: ${VAR+x} is used for variable expansions, preventing unset variable error from set -o nounset.
## When $VAR is not set, we set it to "x" and throw the error.
## This is done in the script that calls the shared_functions.sh

#check for a set variable
function checkVar()
{
	if [[ -z $1 ]]
	then
		EXITCODE=1
		logError "$0 stopped at line $3. \nREASON=$2"
	fi
}




#check for the existence of a directory
#pass in the reason as the second parameter
function checkDir()
{
	if [[ ! -d $1 ]]
	then
		EXITCODE=1
                REASON="$2 does not exist"
		logError "$0 stopped at line $3. \nREASON=${REASON}"
        elif [[ -f $1 ]]
        then
                EXITCODE=1
                REASON="$2 is in fact a file"
                logError "$0 stopped at line $3. \nREASON=${REASON}"
	fi
}


#invoked when the code actually needs to create the directory
function makeDir()
{
        if [[ ! -d $1 ]]
        then
                mkdir -p $1
        elif [[ -d $1 ]]
        then
                EXITCODE=1
                REASON="$2 already exists"
                logWarn "$0 stopped at line $3. \nREASON=${REASON}"
        elif [[ -f $1 ]]
        then
                EXITCODE=1
                REASON="$2 is in fact a file"
                logError "$0 stopped at line $3. \nREASON=${REASON}"
        fi
}



#check for the existence of a file
#pass in the reason as the second parameter
function checkFile()
{
	if [[ ! -s $1 ]]
	then
        	EXITCODE=1
        	logError "$0 stopped at line $3. \nREASON=$2"
	fi
}



#check read group line in Bam for SM entry
#add generic SM value if missing to allow pipeline to run
#Argument 1 = Bam, Argument 2 = read group string, Argument 3 = "tumor", "normal", "germline"
function checkReadGroup()
{
	FIXED_BAM=$(basename ${1} .bam)_rg_fixed.bam
	if [[ ${2} =~ *.SM.* ]]
	then
		echo -e "\n${1} read group line contains SM entry. Continuing.\n"
		FIXED_BAM=${1}
	else
		logWarn "\nNo SM entry found in ${1} read group line. Adding SM:${SAMPLE} to ${1} and re-indexing to continue pipeline.\n"
		OLD_RG=`sed -e "s/@RG //g" <<< ${2}`
		RGID=
		RGLB=
		RGPL=
		RGPU=
		NEW_RG="${OLD_RG}\tSM:${SAMPLE}"
		java -jar ${PICARD}/picard.jar AddOrReplaceReadGroups \
			I=${1} \
			O=${FIXED_BAM} \
			RGSM="SM:${SAMPLE}"
			
#		${SENTIEON}/sentieon driver -r ${REFGEN} --replace_rg ${OLD_RG}=${NEW_RG} -i ${1} --algo ReadWriter ${FIXED_BAM}
#		${SAMTOOLS}/samtools addreplacerg -m overwrite_all -r ${OLD_RG} -r ${NEW_RG} ${1} > ${FIXED_BAM} ## replace read group line
		${SAMTOOLS}/samtools index ${FIXED_BAM}  ## Index new bam
	fi

	## Set variable names based on type of bam
	if [[ ${3} == "normal" ]]
	then
		FIXED_NORMAL=${FIXED_BAM}
	elif [[ ${$3} == "tumor" ]]
	then
		FIXED_TUMOR=${FIXED_BAM}
	elif [[ ${3} != "germline" ]]
	then
		EXITCODE=1
		logError "$0 stopped at line $4.\nREASON=Third argument of checkReadGroup must be normal, tumor, or germline."
	fi
}

#check exit code
#pass in the reason as the second parameter
function checkExitcode()
{
        if [[ $1 -ne 0 ]]
        then
                logError "$0 stopped at line $2 with exit code $1."
        fi
}


