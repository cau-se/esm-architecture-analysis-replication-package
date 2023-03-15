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

checkDirectory "Static data" "${STATIC_DATA_PATH}"
checkDirectory "Source directory" "${SOURCE_CODE_PATH}"
checkDirectory "Processed source directory" "${PROCESSED_CODE_PATH}"
checkExecutable "fxtran" "${FXTRAN}"

# inputs
KIEKER_LOG=${DYNAMIC_DATA_PATH}/`ls ${DYNAMIC_DATA_PATH}/ | grep kieker | grep $NAME`

STATIC_CALL_LOG="${STATIC_DATA_PATH}/calltable.csv"
STATIC_DATAFLOW_LOG="${STATIC_DATA_PATH}/dataflow.csv"

STATIC_COMPONENT_MAP="${STATIC_DATA_PATH}/uvic-map-file.csv"
GLOBAL_FUNCTION_MAP="${STATIC_DATA_PATH}/operation-definitions.csv"

STATIC_LOG_CORRECTED="${STATIC_DATA_PATH}/MITgcm-$NAME/corrected-coupling.csv"
STATIC_MODULE_MAP="${STATIC_DATA_PATH}/module-file-function-map.csv"


information "---------------------------------------------"
information "Processing UVic: Experiment ${EXPERIMENT_NAME}"
information "---------------------------------------------"

information "Create directory/file map"

echo "module;file" > "${STATIC_CALL_LOG}"

for EXT in f f90 f95 ; do
	for I in `find "${SOURCE_CODE_PATH}" -iname "*.$EXT" -printf "%P\n"` ; do
		echo $I	| sed 's/\/\([0-9A-Za-z\-_.]*\)/;\1/' >> "${STATIC_CALL_LOG}"
	done
done

information "Parse processed code"

CURRENT_PATH=`pwd`
cd "${PROCESSED_CODE_PATH}"
for I in `find . -name "*.f"` ; do
	"${FXTRAN}" "$I"
done
cd "${CURRENT_PATH}"

${FXCA} -i "${PROCESSED_CODE_PATH}" -o "${STATIC_DATA_PATH}"


information "Static architecture analysis"

echo "${SAR}" -i "${STATIC_CALL_LOG}" -j "${STATIC_DATAFLOW_LOG}" -c -E "${EXPERIMENT_NAME}" \
	-f "${STATIC_FUNCTION_MAP}" "${ADDITIONAL_FUNCTION_MAP}" "${GLOBAL_FUNCTION_MAP}" \
	-H "${HOST}" \
	-o "${STATIC_FILE_MODEL}" -l static -ns ";" -ds ";" -cs ";"
echo "${SAR}" -i "${STATIC_LOG}" -j "${STATIC_DATAFLOW_LOG}" -c -E "${EXPERIMENT_NAME}" \
	-f "${STATIC_FUNCTION_MAP}" "${ADDITIONAL_FUNCTION_MAP}" "${GLOBAL_FUNCTION_MAP}" \
	-H "${HOST}" -M "${STATIC_MODULE_MAP}" -m "${MISSING_FUNCTIONS_LIST}" \
	-o "${STATIC_FILE_MODEL}" -l static -ns ";" -ds ";" -cs ";"


