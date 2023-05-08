#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

checkExecutable "Restructuring" "${RESTRUCTURING}"
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
		echo "No data."
	fi

	ORIGINAL="${JOB_DIRECTORY}/original-model"

	if [ -d "${ORIGINAL}" ] ; then
		LIST=""

		for J in "${JOB_DIRECTORY}/optimized-"* ; do
			if [ -d "$J" ] ; then
				LIST="$LIST $J"
			fi
		done
		"${RESTRUCTURING}" -i "${ORIGINAL}" $LIST -o "${JOB_DIRECTORY}" -e demo -s kuhn
	fi
done

# end
