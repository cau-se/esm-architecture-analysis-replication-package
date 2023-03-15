#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

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
checkExecutable "fxca" "${FXCA}"

# outputs
STATIC_CALL_LOG="${STATIC_DATA_PATH}/calltable.csv"
STATIC_DATAFLOW_LOG="${STATIC_DATA_PATH}/dataflow.csv"

STATIC_COMPONENT_MAP="${STATIC_DATA_PATH}/module-file-map.csv"
GLOBAL_FUNCTION_MAP="${STATIC_DATA_PATH}/operation-definitions.csv"

information "Create directory/file map"

echo "module;file" > "${STATIC_COMPONENT_MAP}"

for EXT in f f90 f95 ; do
	for I in `find "${SOURCE_CODE_PATH}" -iname "*.$EXT" -printf "%P\n"` ; do
		echo $I	| sed 's/\/\([0-9A-Za-z\-_.]*\)/;\1/' >> "${STATIC_COMPONENT_MAP}"
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

# end
