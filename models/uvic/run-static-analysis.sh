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

checkDirectory "Global data directory" "${GLOBAL_DATA_DIR}"

STATIC_FILE_MODEL="${GLOBAL_DATA_DIR}/file"
STATIC_MAP_MODEL="${GLOBAL_DATA_DIR}/map"
STATIC_COMBINED_MODEL="${GLOBAL_DATA_DIR}/2-level"

checkDirectory "Static file model" "${STATIC_FILE_MODEL}" recreate
checkDirectory "Static map model" "${STATIC_MAP_MODEL}" recreate
checkDirectory "Static 2-level model" "${STATIC_COMBINED_MODEL}" recreate

checkExecutable "sar" "${SAR}"
checkExecutable "maa" "${MAA}"

# inputs
STATIC_CALL_LOG="${STATIC_DATA_PATH}/calltable.csv"
STATIC_DATAFLOW_LOG="${STATIC_DATA_PATH}/dataflow.csv"

STATIC_COMPONENT_MAP="${STATIC_DATA_PATH}/module-file-map.csv"
GLOBAL_FUNCTION_MAP="${STATIC_DATA_PATH}/operation-definitions.csv"

STATIC_LOG_CORRECTED="${STATIC_DATA_PATH}/MITgcm-$NAME/corrected-coupling.csv"
STATIC_MODULE_MAP="${STATIC_DATA_PATH}/module-file-function-map.csv"

information "Static architecture analysis - file based components"

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

"${SAR}" ${INPUTS} -c -E "${EXPERIMENT_NAME}-file" \
	-m file-mode \
	-H "${HOST}" \
	-o "${STATIC_FILE_MODEL}" -l static -ns ";" -ds ";" -cs ";"

information "Static architecture analysis - map based components"

"${SAR}" ${INPUTS} -c -E "${EXPERIMENT_NAME}-map" \
	-M "${STATIC_COMPONENT_MAP}"  -m map-mode \
	-H "${HOST}" \
	-o "${STATIC_MAP_MODEL}" -l static -ns ";" -ds ";" -cs ";"

information "Combine map and file-based info"

"${MAA}" -g "${STATIC_COMPONENT_MAP}" -i "${STATIC_FILE_MODEL}" -o "${STATIC_COMBINED_MODEL}" -gs ";"

# end
