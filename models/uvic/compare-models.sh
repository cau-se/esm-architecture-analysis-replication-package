#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

checkExecutable "Restructuring" "${RESTRUCTURING}"
checkDirectory "Result directory" "${OPTIMIZATION_DATA}"

# main

for I in `ls "${OPTIMIZATION_DATA}"`  ; do

	information "----------------------------------------"
	information $I
	information "----------------------------------------"

	export JOB_DIRECTORY="${OPTIMIZATION_DATA}/$I"

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	cd "${JOB_DIRECTORY}"

	ORIGINAL="original-model"

	if [ -d "${ORIGINAL}" ] ; then
		LIST=""

		for J in "optimized-"* ; do
			if [ -d "$J" ] ; then
				LIST="$LIST $J"
			fi
		done
		"${RESTRUCTURING}" -i "${ORIGINAL}" $LIST -o "${JOB_DIRECTORY}" -e compare -s kuhn
		for J in $LIST ; do
			OPTIMIZED=`basename $J`
	                "${DELTA}" -i "${JOB_DIRECTORY}/original-model-${OPTIMIZED}.xmi" -o "${JOB_DIRECTORY}/original-model-${OPTIMIZED}"
		done
	fi
done

# end
