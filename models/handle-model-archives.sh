#!/bin/bash

# extract = extract optimized and original model from archives
# finalize = pack merged models and remove extracted data from optimized and merged sources
# compress = compress merged models
# restore = extracted merged models

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

checkDirectory "Result directory" "${OPTIMIZATION_DATA}"

if [ "$1" == "" ] ; then
	error "Missing action: extract, compress"
	information "Usage: handle-model-archives.sh <extract|finalize|compress|restore> [JOB_NAME_FRAGMENT]"
	exit 1
else
	ACTION="$1"
	if [ "${ACTION}" == "extract" ] ; then
		information "extract"
	elif [ "${ACTION}" == "finalize" ] ; then
		information "finalize"
	elif [ "${ACTION}" == "compress" ] ; then
		information "compress"
	elif [ "${ACTION}" == "restore" ] ; then
		information "restore"
	elif [ "${ACTION}" == "cleanup" ] ; then
		information "cleanup"
	else
		warn "Unknown action ${ACTION}"
		exit 1
	fi
fi

if [ "$2" == "" ] ; then
	MODEL=""
else
	MODEL="$2"
fi

function extract() {
	export ORIGINAL_ARCHIVE="${JOB_DIRECTORY}/optimized-models.tar.xz"
	export OPTIMIZED_ARCHIVE="${JOB_DIRECTORY}/original-model.tar.xz"
	export COMBINED_ARCHIVE="${JOB_DIRECTORY}/kieker-repositories.tar.xz"

	if [ -f "${ORIGINAL_ARCHIVE}" ] && [ -f "${OPTIMIZED_ARCHIVE}" ] ; then
		tar -xpf "${ORIGINAL_ARCHIVE}"
		tar -xpf "${OPTIMIZED_ARCHIVE}"
	elif [ -f "${COMBINED_ARCHIVE}" ] ; then
		rm -rf "${JOB_DIRECTORY}/original-model"
		for J in "${JOB_DIRECTORY}/optimized-"* ; do
			if [ -d "$J" ] ; then
				rm -rf "$J"
			fi
		done
		tar -xpf "${COMBINED_ARCHIVE}"
		mv "${JOB_DIRECTORY}/kieker-repositories/"* .
	else
		warning "No data."
	fi
}

function restore() {
	export MERGED_MODEL_ARCHIVE="${JOB_DIRECTORY}/merged-models.tar.xz"
	tar -xpf "${MERGED_MODEL_ARCHIVE}"
	mv "${JOB_DIRECTORY}/merged-models/"* "${JOB_DIRECTORY}"
	rmdir merged-models
	# xmi and yaml files
	export MODIFICATIONS_ARCHIVE="${JOB_DIRECTORY}/modifications.tar.xz"
	tar -xpf "${MODIFICATIONS_ARCHIVE}"
	mv modifications/* .
	rmdir modifications
}

function compress() {
	export MERGED_MODEL_ARCHIVE="${JOB_DIRECTORY}/merged-models.tar.xz"
	export MERGED_MODEL_DIR="${JOB_DIRECTORY}/merged-models"
	if [ -d "${MERGED_MODEL_DIR}" ] ; then
		rm -rf "${MERGED_MODEL_DIR}"
	fi
	mkdir -p "${MERGED_MODEL_DIR}"
	mv "${JOB_DIRECTORY}/"merge-optimized-* "${MERGED_MODEL_DIR}"
	tar -cJf "${MERGED_MODEL_ARCHIVE}" merged-models
	rm -rf "${MERGED_MODEL_DIR}"

	# compress csv xmi yaml files
	export MODIFICATIONS_ARCHIVE="${JOB_DIRECTORY}/modifications.tar.xz"
	export MODIFICATIONS_DIR="${JOB_DIRECTORY}/modifications"
	if [ -d "${MODIFICATIONS_DIR}" ] ; then
		rm -rf "${MODIFICATIONS_DIR}"
	fi
	mkdir -p "${MODIFICATIONS_DIR}"
	mv "${JOB_DIRECTORY}/"original-model-optimized-*.* modifications
	tar -cJf "${MODIFICATIONS_ARCHIVE}" modifications
	rm -rf "${MODIFICATIONS_DIR}"
}

function finalize() {
	compress
	cleanup
}

function cleanup() {
        rm -rf "${JOB_DIRECTORY}/original-model"
	for J in "${JOB_DIRECTORY}/optimized-"* ; do
		if [ -d "$J" ] ; then
			rm -rf "$J"
        	fi
	done
}

for JOB_DIRECTORY in `find "${OPTIMIZATION_DATA}" -name "*${MODEL}*job"` ; do
	BASENAME=`basename $JOB_DIRECTORY`
	information "----------------------------------------"
	information $BASENAME $MODE
	information "----------------------------------------"

	export JOB_DIRECTORY

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	export WORK_DIRECTORY=`pwd`

	cd "${JOB_DIRECTORY}"

	if [ "${ACTION}" == "extract" ] ; then
		extract
	elif [ "${ACTION}" == "compress" ] ; then
		compress
	elif [ "${ACTION}" == "restore" ] ; then
		restore
	elif [ "${ACTION}" == "cleanup" ] ; then
		cleanup
	elif [ "${ACTION}" == "finalize" ] ; then
		finalize
	fi

	cd "${WORK_DIRECTORY}"
done


