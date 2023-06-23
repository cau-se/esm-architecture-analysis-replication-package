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
for J in `find "${OPTIMIZATION_DATA}/jss"* -name '*uvic*job'` ; do
	BASENAME=`basename $J`
	information "----------------------------------------"
	information $BASENAME
	information "----------------------------------------"

	export JOB_DIRECTORY="$J"

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	cd "${JOB_DIRECTORY}"

	if [ -f "kieker-repositories.tar.xz" ] ; then
		tar -xpf kieker-repositories.tar.xz
		mv kieker-repositories/* .
	fi

	ORIGINAL="original-model"

	if [ -d "${ORIGINAL}" ] ; then
		LIST=""

		for K in "optimized-"* ; do
			if [ -d "$K" ] ; then
				LIST="$LIST $K"
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
