#!/bin/bash

# Combine static and dynamic models originating from file level, map
# level (directory) and two level modularization architecture recovery.
#
# Combind models can be produced for call based models, dataflow based
# models and models which use class and dataflow together.

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/common-functions.rc"

if [ "$1" != "" ] ; then
        export EXPERIMENT_NAME="$1"
else
        echo "Missing experiment name"
        exit 1
fi

if [ -f "${BASE_DIR}/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Main config file not found."
        exit 1
fi

if [ "$2" != "" ] ; then
	export MODEL="$2"
else
	echo "Missing model identifier"
fi

# set mode call, dataflow or both
checkMode "$3"

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

# variables
export MODEL_DATA_PATH="${DATA_PATH}/$MODEL/${EXPERIMENT_NAME}"

checkDirectory "Model data path" "${MODEL_DATA_PATH}"

STATIC_FILE_MODEL="${MODEL_DATA_PATH}/static-plain-$MODE-file"
STATIC_MAP_MODEL="${MODEL_DATA_PATH}/static-plain-$MODE-map"
STATIC_2_LEVEL_MODEL="${MODEL_DATA_PATH}/static-plain-$MODE-2-level"

IFACE_STATIC_FILE_MODEL="${MODEL_DATA_PATH}/static-iface-$MODE-file"
IFACE_STATIC_MAP_MODEL="${MODEL_DATA_PATH}/static-iface-$MODE-map"
IFACE_STATIC_2_LEVEL_MODEL="${MODEL_DATA_PATH}/static-iface-$MODE-2-level"

DYNAMIC_FILE_MODEL="${MODEL_DATA_PATH}/dynamic-plain-file"
DYNAMIC_MAP_MODEL="${MODEL_DATA_PATH}/dynamic-plain-map"
DYNAMIC_2_LEVEL_MODEL="${MODEL_DATA_PATH}/dynamic-plain-2-level"

IFACE_DYNAMIC_FILE_MODEL="${MODEL_DATA_PATH}/dynamic-iface-file"
IFACE_DYNAMIC_MAP_MODEL="${MODEL_DATA_PATH}/dynamic-iface-map"
IFACE_DYNAMIC_2_LEVEL_MODEL="${MODEL_DATA_PATH}/dynamic-iface-2-level"

COMBINED_FILE_MODEL="${MODEL_DATA_PATH}/combined-plain-$MODE-file"
COMBINED_MAP_MODEL="${MODEL_DATA_PATH}/combined-plain-$MODE-map"
COMBINED_2_LEVEL_MODEL="${MODEL_DATA_PATH}/combined-plain-$MODE-2-level"

IFACE_COMBINED_FILE_MODEL="${MODEL_DATA_PATH}/combined-iface-$MODE-file"
IFACE_COMBINED_MAP_MODEL="${MODEL_DATA_PATH}/combined-iface-$MODE-map"
IFACE_COMBINED_2_LEVEL_MODEL="${MODEL_DATA_PATH}/combined-iface-$MODE-2-level"

# check tools
checkExecutable "Model operations" "${MOP}"

# check inputs
checkDirectory "Static file model" "${STATIC_FILE_MODEL}"
checkDirectory "Static map model" "${STATIC_MAP_MODEL}"
checkDirectory "Static 2-level model" "${STATIC_2_LEVEL_MODEL}"

checkDirectory "Static iface file model" "${IFACE_STATIC_FILE_MODEL}"
checkDirectory "Static iface map model" "${IFACE_STATIC_MAP_MODEL}"
checkDirectory "Static iface 2-level model" "${IFACE_STATIC_2_LEVEL_MODEL}"

checkDirectory "Dynamic file model" "${DYNAMIC_FILE_MODEL}"
checkDirectory "Dynamic map model" "${DYNAMIC_MAP_MODEL}"
checkDirectory "Dynamic 2-level model" "${DYNAMIC_2_LEVEL_MODEL}"

checkDirectory "Dynamic iface file model" "${IFACE_DYNAMIC_FILE_MODEL}"
checkDirectory "Dynamic iface map model" "${IFACE_DYNAMIC_MAP_MODEL}"
checkDirectory "Dynamic iface 2-level model" "${IFACE_DYNAMIC_2_LEVEL_MODEL}"

# check outputs

checkDirectory "Combined file model" "${COMBINED_FILE_MODEL}" recreate
checkDirectory "Combined map model" "${COMBINED_MAP_MODEL}" recreate
checkDirectory "Combined 2-level model" "${COMBINED_2_LEVEL_MODEL}" recreate

checkDirectory "Combined iface file model" "${IFACE_COMBINED_FILE_MODEL}" recreate
checkDirectory "Combined iface map model" "${IFACE_COMBINED_MAP_MODEL}" recreate
checkDirectory "Combined iface 2-level model" "${IFACE_COMBINED_2_LEVEL_MODEL}" recreate

# run
information "Combine models"
"${MOP}" -i "${DYNAMIC_FILE_MODEL}" "${STATIC_FILE_MODEL}" -o "${COMBINED_FILE_MODEL}" -e "${EXPERIMENT_NAME}-combined-plain-$MODE-file" merge
"${MOP}" -i "${DYNAMIC_MAP_MODEL}" "${STATIC_MAP_MODEL}" -o "${COMBINED_MAP_MODEL}" -e "${EXPERIMENT_NAME}-combined-plain-$MODE-map" merge
"${MOP}" -i "${DYNAMIC_2_LEVEL_MODEL}" "${STATIC_2_LEVEL_MODEL}" -o "${COMBINED_2_LEVEL_MODEL}" -e "${EXPERIMENT_NAME}-combined-plain-$MODE-2-level" merge

"${MOP}" -i "${IFACE_DYNAMIC_FILE_MODEL}" "${IFACE_STATIC_FILE_MODEL}" -o "${IFACE_COMBINED_FILE_MODEL}" -e "${EXPERIMENT_NAME}-combined-iface-$MODE-file" merge
"${MOP}" -i "${IFACE_DYNAMIC_MAP_MODEL}" "${IFACE_STATIC_MAP_MODEL}" -o "${IFACE_COMBINED_MAP_MODEL}" -e "${EXPERIMENT_NAME}-combined-iface-$MODE-map" merge
"${MOP}" -i "${IFACE_DYNAMIC_2_LEVEL_MODEL}" "${IFACE_STATIC_2_LEVEL_MODEL}" -o "${IFACE_COMBINED_2_LEVEL_MODEL}" -e "${EXPERIMENT_NAME}-combined-iface-$MODE-2-level" merge

# end
