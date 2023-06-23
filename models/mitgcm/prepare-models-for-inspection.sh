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

checkExecutable "Merge model" "${MOP}"
checkExecutable "Relabel" "${RELABEL}"
checkDirectory "Result directory" "${OPTIMIZATION_DATA}"

# main
for JOB_DIRECTORY in `find "${OPTIMIZATION_DATA}/jss"* -name '*mitgcm*job'` ; do
 	BASENAME=`basename "${JOB_DIRECTORY}"`
	information "----------------------------------------"
	information $BASENAME
	information "----------------------------------------"

	export JOB_DIRECTORY

	checkDirectory "job directory" "${JOB_DIRECTORY}"
	
	export MODEL_ID=`echo "$BASENAME" | sed 's/^jss-jobs-[0-9]*-//g' | sed 's/\.job$//g'`
	
	NAME=`echo "${MODEL_ID}" | cut -d"_" -f2-4`
	MODEL=`echo "${MODEL_ID}" | cut -d"_" -f1`
	MODE=`echo "${MODEL_ID}" | cut -d"_" -f5`
	FORM=`echo "${MODEL_ID}" | cut -d"_" -f6`

	information "  name $NAME"
	information "  model $MODEL"
	information "  mode $MODE"

	SOURCE_LABEL="/home/hs/share/software/restructuring-experiments/architecture-recovery-and-optimization-data/$MODEL/$NAME/$MODE/$FORM"

	cat template.project | sed "s/NAME/$NAME-original/g" > "${JOB_DIRECTORY}/original-model/.project"
	rm -rf "${JOB_DIRECTORY}/original-model-fl"
	mkdir "${JOB_DIRECTORY}/original-model-fl"
	${RELABEL} -i "${JOB_DIRECTORY}/original-model" -o "${JOB_DIRECTORY}/original-model-fl" -r "$SOURCE_LABEL:original" -e "$NAME-original-fl"
	
	for J in `cat "${JOB_DIRECTORY}/med-output.csv" | sed 's/;/\t/g' | awk '{ print $3","$1","$2 }' | sed 's/^\([0-9],\)/00\1/'  | sed 's/^\([0-9]\{2\},\)/0\1/' | sort | head -5` ; do
		ORIGINAL=`echo "$J" | cut -d, -f2 | sed 's/"//g'`
		OPTIMIZED=`echo "$J" | cut -d, -f3 | sed 's/"//g'`
		STEPS=`echo "$J" | cut -d, -f1`
			
		echo "$ORIGINAL -> $OPTIMIZED in $STEPS"
	
		cat template.project | sed "s/NAME/$NAME-$OPTIMIZED/g" > "${JOB_DIRECTORY}/$OPTIMIZED/.project"
		
		rm -rf "${JOB_DIRECTORY}/${OPTIMIZED}-fl"
		mkdir "${JOB_DIRECTORY}/${OPTIMIZED}-fl"
		
		rm -rf "${JOB_DIRECTORY}/merge-${OPTIMIZED}"
		mkdir "${JOB_DIRECTORY}/merge-${OPTIMIZED}"
					
		${RELABEL} -i "${JOB_DIRECTORY}/${OPTIMIZED}" -o "${JOB_DIRECTORY}/${OPTIMIZED}-fl" -r "$SOURCE_LABEL:$OPTIMIZED" -e "$NAME-$OPTIMIZED-fl"
		
		${MOP} -e $NAME-$OPTIMIZED-merged -i "${JOB_DIRECTORY}/original-model-fl" "${JOB_DIRECTORY}/${OPTIMIZED}-fl" -o "${JOB_DIRECTORY}/merge-${OPTIMIZED}" -s all merge
	done
done

# end
