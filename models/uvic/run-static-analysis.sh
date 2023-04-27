#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ "$1" != "" ] ; then
        export EXPERIMENT_NAME="$1"
else
        echo "Missing experiment name"
        exit 1
fi

checkMode $2

if [ -f "${BASE_DIR}/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Config file not found."
        exit 1
fi

# variables
export MODEL_DATA_PATH="${DATA_PATH}/uvic"

STATIC_MODULE_MAP="${MODEL_DATA_PATH}/module-file-map.csv"
GLOBAL_FUNCTION_MAP="${MODEL_DATA_PATH}/operation-definitions.csv"

STATIC_FILE_MODEL="${MODEL_DATA_PATH}/static-plain-file-$MODE"
STATIC_MAP_MODEL="${MODEL_DATA_PATH}/static-plain-map-$MODE"
STATIC_2_LEVEL_MODEL="${MODEL_DATA_PATH}/static-plain-2-level-$MODE"

INTERFACE_FILE_MODEL="${MODEL_DATA_PATH}/static-iface-file-$MODE"
INTERFACE_MAP_MODEL="${MODEL_DATA_PATH}/static-iface-map-$MODE"
INTERFACE_2_LEVEL_MODEL="${MODEL_DATA_PATH}/static-iface-2-level-$MODE"

# check tools and executables
checkExecutable "Static architecture analysis" "${SAR}"
checkExecutable "Model architecture analysis" "${MAA}"

# check inputs
checkDirectory "Static data directory" "${MODEL_DATA_PATH}"
checkFile "Module map" "${STATIC_MODULE_MAP}"
checkFile "Function map" "${GLOBAL_FUNCTION_MAP}"

# check outputs
checkDirectory "Static file model" "${STATIC_FILE_MODEL}" recreate
checkDirectory "Static map model" "${STATIC_MAP_MODEL}" recreate
checkDirectory "Static 2-level model" "${STATIC_2_LEVEL_MODEL}" recreate

checkDirectory "Interface file model" "${INTERFACE_FILE_MODEL}" recreate
checkDirectory "Interface map model" "${INTERFACE_MAP_MODEL}" recreate
checkDirectory "Interface 2-level model" "${INTERFACE_2_LEVEL_MODEL}" recreate

case "$MODE" in
  "call")
     checkFile "Static calls" "${MODEL_DATA_PATH}/calltable.csv"
     ;;
  "dataflow")
     checkFile "Common blocks" "${MODEL_DATA_PATH}/common-blocks.csv"
     checkFile "Dataflow common blocks" "${MODEL_DATA_PATH}/dataflow-cb.csv"
     checkFile "Dataflow caller callee" "${MODEL_DATA_PATH}/dataflow-cc.csv"
     ;;
   "both")
     checkFile "Static calls" "${MODEL_DATA_PATH}/calltable.csv"
     checkFile "Common blocks" "${MODEL_DATA_PATH}/common-blocks.csv"
     checkFile "Dataflow common blocks" "${MODEL_DATA_PATH}/dataflow-cb.csv"
     checkFile "Dataflow caller callee" "${MODEL_DATA_PATH}/dataflow-cc.csv"
     ;;
esac
   
# run
information "Static architecture analysis - file based components"

"${SAR}" -i ${MODEL_DATA_PATH} -g "$MODE" -E "${EXPERIMENT_NAME}-file" \
	-m file-mode \
	-H "${HOST}" \
	-o "${STATIC_FILE_MODEL}" -l static -sc ";"

information "Static architecture analysis - map based components"

"${SAR}" -i ${MODEL_DATA_PATH} -g "$MODE" -E "${EXPERIMENT_NAME}-map" \
	-M "${STATIC_MODULE_MAP}"  -m map-mode \
	-H "${HOST}" \
	-o "${STATIC_MAP_MODEL}" -l static -sc ";"

information "2 level map and file-based info"

"${MAA}" -g "${STATIC_MODULE_MAP}" -i "${STATIC_FILE_MODEL}" -o "${STATIC_2_LEVEL_MODEL}" -gs ";"

information "Compute interface models"
"${MAA}" -i "${STATIC_FILE_MODEL}" -o "${INTERFACE_FILE_MODEL}" -I -c -s
"${MAA}" -i "${STATIC_MAP_MODEL}" -o "${INTERFACE_MAP_MODEL}" -I -c -s
"${MAA}" -i "${STATIC_2_LEVEL_MODEL}" -o "${INTERFACE_2_LEVEL_MODEL}" -I -c -s


# end
