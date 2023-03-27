#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ "$1" != "" ] ; then
        export EXPERIMENT_NAME="$1"
else
        echo "Missing experiment name"
        exit 1
fi

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

# variables
export MITGCM_DATA_PATH="${DATA_PATH}/mitgcm/${EXPERIMENT_NAME}"

STATIC_CALL_LOG="${MITGCM_DATA_PATH}/calltable.csv"
STATIC_DATAFLOW_LOG="${MITGCM_DATA_PATH}/dataflow.csv"

STATIC_MODULE_MAP="${MITGCM_DATA_PATH}/module-file-map.csv"
GLOBAL_FUNCTION_MAP="${MITGCM_DATA_PATH}/operation-definitions.csv"

STATIC_FILE_MODEL="${MITGCM_DATA_PATH}/static/file"
STATIC_MAP_MODEL="${MITGCM_DATA_PATH}/static/map"
STATIC_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/static/2-level"

INTERFACE_FILE_MODEL="${MITGCM_DATA_PATH}/static/iface-file"
INTERFACE_MAP_MODEL="${MITGCM_DATA_PATH}/static/iface-map"
INTERFACE_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/static/iface-2-level"

# check tools and executables
checkExecutable "Static architecture analysis" "${SAR}"
checkExecutable "Model architecture analysis" "${MAA}"

# check inputs
checkDirectory "Static data directory" "${MITGCM_DATA_PATH}"
checkFile "Module map" "${STATIC_MODULE_MAP}"
checkFile "Function map" "${GLOBAL_FUNCTION_MAP}"

# check outputs
checkDirectory "Static file model" "${STATIC_FILE_MODEL}" recreate
checkDirectory "Static map model" "${STATIC_MAP_MODEL}" recreate
checkDirectory "Static 2-level model" "${STATIC_2_LEVEL_MODEL}" recreate

checkDirectory "Interface file model" "${INTERFACE_FILE_MODEL}" recreate
checkDirectory "Interface map model" "${INTERFACE_MAP_MODEL}" recreate
checkDirectory "Interface 2-level model" "${INTERFACE_2_LEVEL_MODEL}" recreate

# prepare
INPUTS=""
if [ -f "${STATIC_CALL_LOG}" ] && [ -f "${STATIC_DATAFLOW_LOG}" ] ; then
	INPUTS="-i ${STATIC_CALL_LOG} -j ${STATIC_DATAFLOW_LOG}"
elif [ -f "${STATIC_CALL_LOG}" ] ; then
	INPUTS="-i ${STATIC_CALL_LOG}"
elif [ -f "${STATIC_DATAFLOW_LOG}" ] ; then
	INPUTS="-j ${STATIC_DATAFLOW_LOG}"
else
	error "No input logs for calls and dataflow available"
	exit 1
fi

# run
information "Static architecture analysis - file based components"

"${SAR}" ${INPUTS} -c -E "${EXPERIMENT_NAME}-file" \
	-m file-mode \
	-H "${HOST}" \
	-o "${STATIC_FILE_MODEL}" -l static -ns ";" -ds ";" -cs ";"

information "Static architecture analysis - map based components"

"${SAR}" ${INPUTS} -c -E "${EXPERIMENT_NAME}-map" \
	-M "${STATIC_MODULE_MAP}"  -m map-mode \
	-H "${HOST}" \
	-o "${STATIC_MAP_MODEL}" -l static -ns ";" -ds ";" -cs ";"

information "2 level map and file-based info"

"${MAA}" -g "${STATIC_MODULE_MAP}" -i "${STATIC_FILE_MODEL}" -o "${STATIC_2_LEVEL_MODEL}" -gs ";"

information "Compute interface models"
"${MAA}" -i "${STATIC_FILE_MODEL}" -o "${INTERFACE_FILE_MODEL}" -I -c -s
"${MAA}" -i "${STATIC_MAP_MODEL}" -o "${INTERFACE_MAP_MODEL}" -I -c -s
"${MAA}" -i "${STATIC_2_LEVEL_MODEL}" -o "${INTERFACE_2_LEVEL_MODEL}" -I -c -s


# end
