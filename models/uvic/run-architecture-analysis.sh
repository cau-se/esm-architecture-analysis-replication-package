#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ "$1" != "" ] ; then
        export NAME="$1"
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

# inputs
checkDirectory "Dynamic data" "${DYNAMIC_DATA_PATH}"
checkDirectory "Static data" "${STATIC_DATA_PATH}"

# outputs
DYNAMIC_RESULT="$BASE_DIR/dynamic-result"
DYNAMIC_FILE_MODEL="$BASE_DIR/dynamic-model/file-$NAME"
DYNAMIC_MAP_MODEL="$BASE_DIR/dynamic-model/map-$NAME"

STATIC_RESULT="$BASE_DIR/static-result"
STATIC_FILE_MODEL="$BASE_DIR/static-model/file-$NAME"
STATIC_MAP_MODEL="$BASE_DIR/static-model/map-$NAME"

COMBINED_RESULT="$BASE_DIR/combined-result"
COMBINED_FILE_MODEL="$BASE_DIR/combined-model/file-$NAME"
COMBINED_MAP_MODEL="$BASE_DIR/combined-model/map-$NAME"

INTERFACE_RESULT="$BASE_DIR/interface-result"
INTERFACE_FILE_MODEL="$BASE_DIR/interface-model/file-$NAME"
INTERFACE_MAP_MODEL="$BASE_DIR/interface-model/map-$NAME"

# inputs
KIEKER_LOG=${DYNAMIC_DATA_PATH}/`ls ${DYNAMIC_DATA_PATH}/ | grep kieker | grep $NAME`

STATIC_LOG="${STATIC_DATA_PATH}/MITgcm-$NAME/coupling.csv"
STATIC_DATAFLOW_LOG="${STATIC_DATA_PATH}/MITgcm-$NAME/dataflow.csv"

STATIC_FUNCTION_MAP="${STATIC_DATA_PATH}/MITgcm-$NAME/functionnames.csv"
ADDITIONAL_FUNCTION_MAP="${STATIC_DATA_PATH}/additional-functionnames.csv"
GLOBAL_FUNCTION_MAP="${STATIC_DATA_PATH}/mitgcm-functionnames.csv"

STATIC_LOG_CORRECTED="${STATIC_DATA_PATH}/MITgcm-$NAME/corrected-coupling.csv"
STATIC_MODULE_MAP="${STATIC_DATA_PATH}/module-file-function-map.csv"

EXECUTABLE="${REPOSITORY_DIR}/run/UVic_ESCM"

## check tools and directories
checkExecutable "dynamic architecture analysis" "${DAR}"
checkExecutable "dynamic architecture analysis" "${SAR}"
checkExecutable "mop merge models" "${MOP}"
checkExecutable "computing interfaces" "${MAA}"
checkExecutable "visualization and statistics" "${MVIS}"

## check directories and data
checkDirectory "Kieker Log" "${KIEKER_LOG}"
checkFile "Static Log" "${STATIC_LOG}"
checkFile "Static dataflow Log" "${STATIC_DATAFLOW_LOG}"
checkFile "Static function map" "${STATIC_FUNCTION_MAP}"
checkFile "Static module map" "${STATIC_MODULE_MAP}"

checkFile "Executable" "${EXECUTABLE}"
checkFile "addr2line" "${ADDR2LINE}"

# Creating directories
prepareDirectory "${DYNAMIC_RESULT}"
prepareDirectory "${DYNAMIC_FILE_MODEL}"
prepareDirectory "${DYNAMIC_MAP_MODEL}"

prepareDirectory "${STATIC_RESULT}"
prepareDirectory "${STATIC_FILE_MODEL}"
prepareDirectory "${STATIC_MAP_MODEL}"

prepareDirectory "${COMBINED_RESULT}"
prepareDirectory "${COMBINED_FILE_MODEL}"
prepareDirectory "${COMBINED_MAP_MODEL}"

prepareDirectory "${INTERFACE_RESULT}"
prepareDirectory "${INTERFACE_FILE_MODEL}"
prepareDirectory "${INTERFACE_MAP_MODEL}"

information "------------------------------------------------"
information "${NAME}"
information "------------------------------------------------"


information "Process dynamic data to model"
"${DAR}" -i "${KIEKER_LOG}" -c -o "${DYNAMIC_FILE_MODEL}" -e "${EXECUTABLE}" \
	-a "${ADDR2LINE}" -E "${EXPERIMENT_NAME}" -l dynamic -m file-mode -s elf
"${DAR}" -i "${KIEKER_LOG}" -c -o "${DYNAMIC_MAP_MODEL}" -e "${EXECUTABLE}" \
	-a "${ADDR2LINE}" -E "${EXPERIMENT_NAME}" \
	-l dynamic -m map-mode -s elf -M "${STATIC_MODULE_MAP}"

#information "Process static data to model"
"${SAR}" -i "${STATIC_LOG}" -j "${STATIC_DATAFLOW_LOG}" -c -E "${EXPERIMENT_NAME}" \\
	-f "${STATIC_FUNCTION_MAP}" "${ADDITIONAL_FUNCTION_MAP}" "${GLOBAL_FUNCTION_MAP}" \\
	-H "${HOST}" \\
	-o "${STATIC_FILE_MODEL}" -l static -ns ";" -ds ";" -cs ";"
"${SAR}" -i "${STATIC_LOG}" -j "${STATIC_DATAFLOW_LOG}" -c -E "${EXPERIMENT_NAME}" \\
	-f "${STATIC_FUNCTION_MAP}" "${ADDITIONAL_FUNCTION_MAP}" "${GLOBAL_FUNCTION_MAP}" \\
	-H "${HOST}" -M "${STATIC_MODULE_MAP}" -m "${MISSING_FUNCTIONS_LIST}" \\
	-o "${STATIC_FILE_MODEL}" -l static -ns ";" -ds ";" -cs ";"

#information "Combine models"
"${MOP}" -i "${DYNAMIC_FILE_MODEL}" "${STATIC_FILE_MODEL}" -o "${COMBINED_FILE_MODEL}" -e merged
"${MOP}" -i "${DYNAMIC_MAP_MODEL}" "${STATIC_MAP_MODEL}" -o "${COMBINED_MAP_MODEL}" -e merged

information "Compute Interfaces"
"${MAA}" -i "${DYNAMIC_FILE_MODEL}" -o "${INTERFACE_FILE_MODEL}" -I -c -s
"${MAA}" -i "${DYNAMIC_MAP_MODEL}" -o "${INTERFACE_MAP_MODEL}" -I -c -s
"${MAA}" -i "${COMBINED_FILE_MODEL}" -o "${INTERFACE_FILE_MODEL}" -I -c -s
"${MAA}" -i "${COMBINED_MAP_MODEL}" -o "${INTERFACE_MAP_MODEL}" -I -c -s

information "Compute statistics"
"${MVIS}" -i "${DYNAMIC_FILE_MODEL}" -o "${DYNAMIC_RESULT}" -s all -g dot-op dot-component -m add-nodes
"${MVIS}" -i "${STATIC_FILE_MODEL}" -o "${STATIC_RESULT}" -s all -g dot-op dot-component -m add-nodes
"${MVIS}" -i "${COMBINED_FILE_MODEL}" -o "${COMBINED_RESULT}" -s all -g dot-op dot-component -m add-nodes
"${MVIS}" -i "${INTERFACE_FILE_MODEL}" -o "${INTERFACE_RESULT}" -s all -g dot-op dot-component -m add-nodes

"${MVIS}" -i "${DYNAMIC_MAP_MODEL}" -o "${DYNAMIC_RESULT}" -s all -g dot-op dot-component -m add-nodes
"${MVIS}" -i "${STATIC_MAP_MODEL}" -o "${STATIC_RESULT}" -s all -g dot-op dot-component -m add-nodes
"${MVIS}" -i "${COMBINED_MAP_MODEL}" -o "${COMBINED_RESULT}" -s all -g dot-op dot-component -m add-nodes
"${MVIS}" -i "${INTERFACE_MAP_MODEL}" -o "${INTERFACE_RESULT}" -s all -g dot-op dot-component -m add-nodes

information ""
information "Done"
information ""

# end
