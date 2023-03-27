#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ "$1" != "" ] ; then
	EXPERIMENT_NAME="$1"
else
	echo "Missing mitgcm variant"
	exit 1
fi

if [ -f "$BASE_DIR/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Config file not found."
        exit 1
fi

# variables
export MITGCM_DATA_PATH="${DATA_PATH}/mitgcm/${EXPERIMENT_NAME}"
export KIEKER_LOG=${MITGCM_DATA_PATH}/`ls "${MITGCM_DATA_PATH}" | grep kieker`

DYNAMIC_FILE_MODEL="${MITGCM_DATA_PATH}/dynamic/file"
DYNAMIC_MAP_MODEL="${MITGCM_DATA_PATH}/dynamic/map"
DYNAMIC_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/dynamic/2-level"

INTERFACE_FILE_MODEL="${MITGCM_DATA_PATH}/dynamic/iface-file"
INTERFACE_MAP_MODEL="${MITGCM_DATA_PATH}/dynamic/iface-map"
INTERFACE_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/dynamic/iface-2-level"

STATIC_MODULE_MAP="${MITGCM_DATA_PATH}/module-file-map.csv"

## check tools
checkExecutable "dynamic architecture analysis" "${DAR}"
checkExecutable "maa" "${MAA}"
checkExecutable "Executable" "${EXECUTABLE}"
checkExecutable "addr2line" "${ADDR2LINE}"

# check inputs
checkDirectory "Dynamic data directory" "${MITGCM_DATA_PATH}"
checkDirectory "Kieker Log" "${KIEKER_LOG}"
checkFile "Static module map" "${STATIC_MODULE_MAP}"

## check outputs
checkDirectory "Dynamic file model" "${DYNAMIC_FILE_MODEL}" recreate
checkDirectory "Dynamic map model" "${DYNAMIC_MAP_MODEL}" recreate
checkDirectory "Dynamic 2-level model" "${DYNAMIC_2_LEVEL_MODEL}" recreate

checkDirectory "Interface file model" "${INTERFACE_FILE_MODEL}" recreate
checkDirectory "Interface map model" "${INTERFACE_MAP_MODEL}" recreate
checkDirectory "Interface 2-level model" "${INTERFACE_2_LEVEL_MODEL}" recreate

# run

information "Dynamic architecture analysis - file based components"

"${DAR}" -a "${ADDR2LINE}" -c -e "${EXECUTABLE}" -E "${NAME}" -i "${KIEKER_LOG}" -m file-mode -o "${DYNAMIC_FILE_MODEL}" -s elf -l dynamic

information "Dynamic architecture analysis - map based components"

"${DAR}" -a "${ADDR2LINE}" -c -e "${EXECUTABLE}" -E "${NAME}" -i "${KIEKER_LOG}" -m map-mode -o "${DYNAMIC_MAP_MODEL}" -s elf -l dynamic -M "${STATIC_MODULE_MAP}"

information "2 level map and file-based info"

"${MAA}" -g "${STATIC_MODULE_MAP}" -i "${DYNAMIC_FILE_MODEL}" -o "${DYNAMIC_2_LEVEL_MODEL}" -gs ";"

information "Compute interface models"
"${MAA}" -i "${DYNAMIC_FILE_MODEL}" -o "${INTERFACE_FILE_MODEL}" -I -c -s
"${MAA}" -i "${DYNAMIC_MAP_MODEL}" -o "${INTERFACE_MAP_MODEL}" -I -c -s
"${MAA}" -i "${DYNAMIC_2_LEVEL_MODEL}" -o "${INTERFACE_2_LEVEL_MODEL}" -I -c -s

# end
