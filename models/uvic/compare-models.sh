#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ -f "${BASE_DIR}/../config" ] ; then
        . "${BASE_DIR}/../config"
else
        echo "Main config file not found."
        exit 1
fi
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
for JOB_DIRECTORY in `find "${OPTIMIZATION_DATA}" -name '*uvic*job'` ; do
	BASENAME=`basename $JOB_DIRECTORY`
	information "----------------------------------------"
	information $BASENAME
	information "----------------------------------------"

	export JOB_DIRECTORY

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	ORIGINAL="${JOB_DIRECTORY}/original-model"

	if [ -d "${ORIGINAL}" ] ; then
		LIST=""

		for J in "${JOB_DIRECTORY}/optimized-"* ; do
			if [ -d "$J" ] ; then
				LIST="$LIST $J"
			fi
		done
		"${RESTRUCTURING}" -i "${ORIGINAL}" $LIST -o "${JOB_DIRECTORY}" -e compare -s kuhn
		for K in $LIST ; do
			OPTIMIZED=`basename $K`
		        "${DELTA}" -i "${JOB_DIRECTORY}/original-model-${OPTIMIZED}.xmi" -o "${JOB_DIRECTORY}/original-model-${OPTIMIZED}"
		done
	fi
done

# end
