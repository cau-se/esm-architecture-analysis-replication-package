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

for I in jss-jobs-58-a-uvic_combined_iface-map-common.job \
jss-jobs-58-b-uvic_combined_iface-map-embm.job \
jss-jobs-58-c-uvic_combined_iface-map-mom.job \
jss-jobs-59-a-uvic_combined_map-common.job \
jss-jobs-59-b-uvic_combined_map-embm.job \
jss-jobs-59-c-uvic_combined_map-mom.job \
jss-jobs-64-a-uvic_dynamic_iface-map-common.job \
jss-jobs-64-b-uvic_dynamic_iface-map-embm.job \
jss-jobs-64-c-uvic_dynamic_iface-map-mom.job \
jss-jobs-65-a-uvic_dynamic_map-common.job \
jss-jobs-65-b-uvic_dynamic_map-embm.job \
jss-jobs-65-c-uvic_dynamic_map-mom.job \
jss-jobs-70-a-uvic_static_iface-map-common.job \
jss-jobs-70-b-uvic_static_iface-map-embm.job \
jss-jobs-70-c-uvic_static_iface-map-mom.job \
jss-jobs-71-a-uvic_static_map-common.job \
jss-jobs-71-b-uvic_static_map-embm.job \
jss-jobs-71-c-uvic_static_map-mom.job ; do

	information "----------------------------------------"
	information $I
	information "----------------------------------------"

	export JOB_DIRECTORY="${OPTIMIZATION_DATA}/$I"

	checkDirectory "job directory" "${JOB_DIRECTORY}"

	P=`echo "$I" | sed 's/^jss-jobs-[0-9]*-//g' | sed 's/\.job$//g'`

	NAME="2.9"
	MODEL=`echo "$P" | cut -d"_" -f1`
	MODE=`echo "$P" | cut -d"_" -f2`
	FORM=`echo "$P" | cut -d"_" -f3 | sed 's/-\w*$//g'`

	echo $NAME
	echo $MODEL
	echo $MODE
	echo $FORM

	SOURCE_LABEL="/home/hs/share/software/restructuring-experiments/architecture-recovery-and-optimization-data/uvic/$MODE/$FORM"

	cat template.project | sed "s/NAME/$NAME-original/g" > "${JOB_DIRECTORY}/original-model/.project"
	rm -rf "${JOB_DIRECTORY}/original-model-fl"
	mkdir "${JOB_DIRECTORY}/original-model-fl"
	${RELABEL} -i "${JOB_DIRECTORY}/original-model" -o "${JOB_DIRECTORY}/original-model-fl" -r "$SOURCE_LABEL:original" -e "$NAME-original-fl"

	for J in `cat "${JOB_DIRECTORY}/med-output.csv" | sed 's/;/\t/g' | awk '{ print $3","$1","$2 }' | sed 's/^\([0-9],\)/00\1/'  | sed 's/^\([0-9]\{2\},\)/0\1/' | sort | head -5` ; do
		ORIGINAL=`echo "$J" | cut -d, -f2 | sed 's/"//g'`
		OPTIMIZED=`echo "$J" | cut -d, -f3 | sed 's/"//g'`
		STEPS=`echo "$J" | cut -d, -f1`

		echo "$ORIGINAL -> $OPTIMIZED in $STEPS"

		cat template.project | sed "s/NAME/$P-$OPTIMIZED/g" > "${JOB_DIRECTORY}/$OPTIMIZED/.project"

		rm -rf "${JOB_DIRECTORY}/${OPTIMIZED}-fl"
		mkdir "${JOB_DIRECTORY}/${OPTIMIZED}-fl"

		rm -rf "${JOB_DIRECTORY}/merge-${OPTIMIZED}"
		mkdir "${JOB_DIRECTORY}/merge-${OPTIMIZED}"

		${RELABEL} -i "${JOB_DIRECTORY}/${OPTIMIZED}" -o "${JOB_DIRECTORY}/${OPTIMIZED}-fl" -r "$SOURCE_LABEL:$OPTIMIZED" -e "$NAME-$OPTIMIZED-fl"

		${MOP} -e $P-$OPTIMIZED-merged -i "${JOB_DIRECTORY}/original-model-fl" "${JOB_DIRECTORY}/${OPTIMIZED}-fl" -o "${JOB_DIRECTORY}/merge-${OPTIMIZED}" -s all merge
	done
done

# end
