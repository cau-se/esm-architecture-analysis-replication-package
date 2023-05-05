#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

RESTRUCTURING="/home/reiner/temp/experiment/install/oceandsl-tools/bin/restructuring"
OPTIMIZATION_DATA="/home/reiner/jss-results"

checkExecutable "Restructuring" "${RESTRUCTURING}"
checkDirectory "Result directory" "${OPTIMIZATION_DATA}"


# main

for I in jss-jobs-22-mitgcm_tutorial_barotropic_gyre_combined_iface-map.job \
jss-jobs-23-mitgcm_tutorial_barotropic_gyre_combined_map.job \
jss-jobs-28-mitgcm_tutorial_barotropic_gyre_dynamic_iface-map.job \
jss-jobs-29-mitgcm_tutorial_barotropic_gyre_dynamic_map.job \
jss-jobs-34-mitgcm_tutorial_barotropic_gyre_static_iface-map.job \
jss-jobs-35-mitgcm_tutorial_barotropic_gyre_static_map.job \
jss-jobs-58-a-uvic_combined_iface-map-common.job \
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

	export ORIGINAL_ARCHIVE="${OPTIMIZATION_DATA}/$I/optimized-models.tar.xz"
	export OPTIMIZED_ARCHIVE="${OPTIMIZATION_DATA}/$I/original-model.tar.xz"

	if [ -f "${ORIGINAL_ARCHIVE}" ] && [ -f "${OPTIMIZED_ARCHIVE}" ] ; then

		cd "${OPTIMIZATION_DATA}/$I"

		tar -xpf $ORIGINAL_ARCHIVE
		tar -xpf $OPTIMIZED_ARCHIVE

		ORIGINAL="${OPTIMIZATION_DATA}/$I/original-model"

		LIST=""

		for J in "${OPTIMIZATION_DATA}/$I/optimized-"* ; do
			if [ -d "$J" ] ; then
				LIST="$LIST $J"
			fi
		done
		"${RESTRUCTURING}" -i "${ORIGINAL}" $LIST -o "${OPTIMIZATION_DATA}/$I" -e demo -s kuhn
	else
		echo "No data."
	fi
done

# end
