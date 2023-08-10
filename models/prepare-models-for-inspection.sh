#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/common-functions.rc"

if [ -f "${BASE_DIR}/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Main config file not found."
        exit 1
fi

if [ "$1" != "" ] ; then
	export MODEL="$1"
else
	echo "Missing model identifier"
fi

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

checkExecutable "Merge model" "${MOP}"
checkExecutable "Relabel" "${RELABEL}"
checkDirectory "Result directory" "${OPTIMIZATION_DATA}"

export MOP_LOG="${BASE_DIR}/mop.log"

rm -f "${MOP_LOG}"
touch "${MOP_LOG}"

# main
COUNT=0
for JOB_DIRECTORY in `find "${OPTIMIZATION_DATA}" -name "*${MODEL}*job"` ; do
	BASENAME=`basename "${JOB_DIRECTORY}"`
	information "----------------------------------------"
	information $BASENAME
	information "----------------------------------------"

	export JOB_DIRECTORY

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	export MODEL_ID=`echo "$BASENAME" | sed 's/^jss-jobs-[0-9]*-//g' | sed 's/\.job$//g'`

	cd "${JOB_DIRECTORY}"

	if [ -f "med-output.csv" ] ; then
		cat "${BASE_DIR}/template.project" | sed "s/NAME/${MODEL_ID}-original/g" > "original-model/.project"

		for J in `tail -n +2 "med-output.csv" | sed 's/;/\t/g' | awk '{ print $3,$1,$2 }' | sed 's/,//g' | awk '{ print $1","$2","$3 }'` ; do
			ORIGINAL=`echo "$J" | cut -d, -f2 | sed 's/"//g'`
			OPTIMIZED=`echo "$J" | cut -d, -f3 | sed 's/"//g'`
			STEPS=`echo "$J" | cut -d, -f1`

			information "$ORIGINAL -> $OPTIMIZED in $STEPS steps"

			if [ -d "$OPTIMIZED" ] ; then
				cat "${BASE_DIR}/template.project" | sed "s/NAME/${MODEL_ID}-$OPTIMIZED/g" > "$OPTIMIZED/.project"

				rm -rf "merge-${OPTIMIZED}"
				mkdir "merge-${OPTIMIZED}"

				if [ "$COUNT" -lt 8 ] ; then
					"${MOP}" -e "${MODEL_ID}-${OPTIMIZED}-merged" -i "original-model" "${OPTIMIZED}" -o "merge-${OPTIMIZED}" -s all nearest-merge >> "${MOP_LOG}" 2>&1 &
					COUNT=`expr $COUNT + 1`
				else
					"${MOP}" -e "${MODEL_ID}-${OPTIMIZED}-merged" -i "original-model" "${OPTIMIZED}" -o "merge-${OPTIMIZED}" -s all nearest-merge >> "${MOP_LOG}" 2>&1
					COUNT=0
				fi
			else
				warning "Missing $OPTIMIZED model"
			fi
		done
	else
		error "Missing MED output for job $BASENAME"
	fi
done

# end
