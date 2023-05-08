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
