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

for I in jss-jobs-22-mitgcm_tutorial_barotropic_gyre_combined_iface-map.job \
jss-jobs-23-mitgcm_tutorial_barotropic_gyre_combined_map.job \
jss-jobs-28-mitgcm_tutorial_barotropic_gyre_dynamic_iface-map.job \
jss-jobs-29-mitgcm_tutorial_barotropic_gyre_dynamic_map.job \
jss-jobs-34-mitgcm_tutorial_barotropic_gyre_static_iface-map.job \
jss-jobs-35-mitgcm_tutorial_barotropic_gyre_static_map.job ; do

	information "----------------------------------------"
	information $I
	information "----------------------------------------"

	export JOB_DIRECTORY="${OPTIMIZATION_DATA}/$I"

	checkDirectory "job directory" "${JOB_DIRECTORY}"
	
	P=`echo "$I" | sed 's/^jss-jobs-[0-9]*-//g' | sed 's/\.job$//g'`
	
	NAME=`echo "$P" | cut -d"_" -f2-4`
	MODEL=`echo "$P" | cut -d"_" -f1`
	MODE=`echo "$P" | cut -d"_" -f5`
	FORM=`echo "$P" | cut -d"_" -f6`

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
