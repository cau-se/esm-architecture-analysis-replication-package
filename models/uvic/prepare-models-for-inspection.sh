#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

checkExecutable "Merge model" "${MOP}"
checkExecutable "Relabel" "${RELABEL}"
checkDirectory "Result directory" "${OPTIMIZATION_DATA}"

# main

for I in `ls "${OPTIMIZATION_DATA}"` ; do

	information "----------------------------------------"
	information $I
	information "----------------------------------------"

	export JOB_DIRECTORY="${OPTIMIZATION_DATA}/$I"

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	export MODEL_ID=`echo "$I" | sed 's/^jss-jobs-[0-9]*-//g' | sed 's/\.job$//g'`

	NAME="2.9"
	MODEL=`echo "${MODEL_ID}" | cut -d"_" -f1`
	MODE=`echo "${MODEL_ID}" | cut -d"_" -f2`
	FORM=`echo "${MODEL_ID}" | cut -d"_" -f3 | sed 's/-\w*$//g'`

	information "  name $NAME"
	information "  model $MODEL"
	information "  mode $MODE"
	
	cd "${JOB_DIRECTORY}"

	if [ -f "med-output.csv" ] ; then

		cat "${BASE_DIR}/template.project" | sed "s/NAME/$NAME-original/g" > "${JOB_DIRECTORY}/original-model/.project"

		for J in `cat "med-output.csv" | sed 's/;/\t/g' | awk '{ print $3","$1","$2 }' | sed 's/^\([0-9],\)/00\1/'  | sed 's/^\([0-9]\{2\},\)/0\1/' | sort` ; do
			ORIGINAL=`echo "$J" | cut -d, -f2 | sed 's/"//g'`
			OPTIMIZED=`echo "$J" | cut -d, -f3 | sed 's/"//g'`
			STEPS=`echo "$J" | cut -d, -f1`

			echo "$ORIGINAL -> $OPTIMIZED in $STEPS"

			cat "${BASE_DIR}/template.project" | sed "s/NAME/${MODEL_ID}-$OPTIMIZED/g" > "${JOB_DIRECTORY}/$OPTIMIZED/.project"

			rm -rf "${JOB_DIRECTORY}/merge-${OPTIMIZED}"
			mkdir "${JOB_DIRECTORY}/merge-${OPTIMIZED}"

			${MOP} -e "${MODEL_ID}-${OPTIMIZED}-merged" -i "original-model" "${OPTIMIZED}" -o "merge-${OPTIMIZED}" -s all merge
		done
	else
		error "Missing MED output for job $I"
	fi
done

# end
