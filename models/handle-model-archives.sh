#!/bin/bash


export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

checkDirectory "Result directory" "${OPTIMIZATION_DATA}"

for JOB_DIRECTORY in `find "${OPTIMIZATION_DATA}" -name '*job'` ; do
	BASENAME=`basename $JOB_DIRECTORY`
	information "----------------------------------------"
	information $BASENAME
	information "----------------------------------------"

	export JOB_DIRECTORY

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	export ORIGINAL_ARCHIVE="${JOB_DIRECTORY}/optimized-models.tar.xz"
	export OPTIMIZED_ARCHIVE="${JOB_DIRECTORY}/original-model.tar.xz"
	export COMBINED_ARCHIVE="${JOB_DIRECTORY}/kieker-repositories.tar.xz"

	cd "${JOB_DIRECTORY}"

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
done


