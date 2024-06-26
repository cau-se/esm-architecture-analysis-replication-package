#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../common-functions.rc"

if [ "$1" != "" ] ; then
        export EXPERIMENT_NAME="$1"
else
        echo "Missing experiment name"
        exit 1
fi

if [ -f "${BASE_DIR}/../config" ] ; then
        . "${BASE_DIR}/../config"
else
        echo "Main config file not found."
        exit 1
fi
if [ -f "${BASE_DIR}/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Config file not found."
        exit 1
fi

# variables
export MODEL_DATA_PATH="${DATA_PATH}/uvic"
export KIEKER_LOG=${MODEL_DATA_PATH}/`ls "${MODEL_DATA_PATH}" | grep kieker`

DYNAMIC_FILE_MODEL="${MODEL_DATA_PATH}/dynamic-plain-file"
DYNAMIC_MAP_MODEL="${MODEL_DATA_PATH}/dynamic-plain-map"
DYNAMIC_2_LEVEL_MODEL="${MODEL_DATA_PATH}/dynamic-plain-2-level"

INTERFACE_FILE_MODEL="${MODEL_DATA_PATH}/dynamic-iface-file"
INTERFACE_MAP_MODEL="${MODEL_DATA_PATH}/dynamic-iface-map"
INTERFACE_2_LEVEL_MODEL="${MODEL_DATA_PATH}/dynamic-iface-2-level"

STATIC_MODULE_MAP="${MODEL_DATA_PATH}/module-file-map.csv"

EXECUTABLE="${REPOSITORY_DIR}/run/UVic_ESCM"

# check tools and executables
checkExecutable "dynamic architecture analysis" "${DAR}"
checkExecutable "Model architecture analysis" "${MAA}"
checkExecutable "Executable" "${EXECUTABLE}"
checkExecutable "addr2line" "${ADDR2LINE}"

# check inputs
checkDirectory "Dynamic data directory" "${MODEL_DATA_PATH}"
checkDirectory "Kieker Log" "${KIEKER_LOG}"
checkFile "Static module map" "${STATIC_MODULE_MAP}"

# check outputs
checkDirectory "Dynamic file model" "${DYNAMIC_FILE_MODEL}" recreate
checkDirectory "Dynamic map model" "${DYNAMIC_MAP_MODEL}" recreate
checkDirectory "Dynamic 2-level model" "${DYNAMIC_2_LEVEL_MODEL}" recreate

checkDirectory "Interface file model" "${INTERFACE_FILE_MODEL}" recreate
checkDirectory "Interface map model" "${INTERFACE_MAP_MODEL}" recreate
checkDirectory "Interface 2-level model" "${INTERFACE_2_LEVEL_MODEL}" recreate

# run
information "Dynamic architecture analysis - file based components"
"${DAR}" -a "${ADDR2LINE}" -c -e "${EXECUTABLE}" -E "${EXPERIMENT_NAME}-dynamic-call" -i "${KIEKER_LOG}" -m file-mode -o "${DYNAMIC_FILE_MODEL}" -s elf -l dynamic

information "Dynamic architecture analysis - map based components"

"${DAR}" -a "${ADDR2LINE}" -c -e "${EXECUTABLE}" -E "${EXPERIMENT_NAME}-dynamic-call" -i "${KIEKER_LOG}" -m map-mode -o "${DYNAMIC_MAP_MODEL}" -s elf -l dynamic -M "${STATIC_MODULE_MAP}"

information "2 level map and file-based info"
"${MAA}" -g "${STATIC_MODULE_MAP}" -i "${DYNAMIC_FILE_MODEL}" -o "${DYNAMIC_2_LEVEL_MODEL}" -gs ";" -E "${EXPERIMENT_NAME}-dynamic-plain-call-2-level"

information "Compute interface models"
"${MAA}" -i "${DYNAMIC_FILE_MODEL}" -o "${INTERFACE_FILE_MODEL}" -I -c -s -E "${EXPERIMENT_NAME}-dynamic-iface-call-file"
"${MAA}" -i "${DYNAMIC_MAP_MODEL}" -o "${INTERFACE_MAP_MODEL}" -I -c -s -E "${EXPERIMENT_NAME}-dynamic-iface-call-map"
"${MAA}" -i "${DYNAMIC_2_LEVEL_MODEL}" -o "${INTERFACE_2_LEVEL_MODEL}" -I -c -s -E "${EXPERIMENT_NAME}-dynamic-iface-call-2-level"

# end
