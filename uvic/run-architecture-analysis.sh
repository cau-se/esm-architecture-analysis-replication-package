#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

if [ ! -d "${DYNAMIC_DATA_PATH}" ] ; then
	echo "DYNAMIC_DATA_PATH missing or not a directory."
	exit 1
fi
if [ ! -d "${STATIC_DATA_PATH}" ] ; then
	echo "STATIC_DATA_PATH missing or not a directory."
	exit 1
fi

DYNAMIC_RESULT="$BASE_DIR/dynamic-result"
DYNAMIC_FILE_MODEL="$BASE_DIR/dynamic-model/file"
DYNAMIC_MAP_MODEL="$BASE_DIR/dynamic-model/map"

COMBINED_RESULT="$BASE_DIR/combined-result"
COMBINED_FILE_MODEL="$BASE_DIR/combined-model/file"
COMBINED_MAP_MODEL="$BASE_DIR/combined-model/map"

KIEKER_LOG="${DYNAMIC_DATA_PATH}"
STATIC_LOG="${STATIC_DATA_PATH}/callgraph.csv"

STATIC_FUNCTION_MAP="${STATIC_DATA_PATH}/functionnames.csv"
ADDITIONAL_FUNCTION_MAP="${STATIC_DATA_PATH}/additional-functionnames.csv"

STATIC_LOG_CORRECTED="${STATIC_DATA_PATH}/corrected-coupling.csv"
STATIC_MODULE_MAP="${STATIC_DATA_PATH}/module-file-function-map.csv"

if [ ! -d "${KIEKER_LOG}" ] ; then
        echo "Cannot find kieker log ${KIEKER_LOG}"
        exit 1
fi
if [ ! -f "${STATIC_LOG}" ] ; then
        echo "Cannot find static log ${STATIC_LOG}"
        exit 1
fi
if [ ! -f "${STATIC_FUNCTION_MAP}" ] ; then
        echo "Cannot find function map ${STATIC_FUNCTION_MAP}"
        exit 1
fi

# Creating directories
if [ -d "${DYNAMIC_RESULT}" ] ; then
	rm -f ${DYNAMIC_RESULT}/*
else
        mkdir -p "${DYNAMIC_RESULT}"
fi

if [ -d "${DYNAMIC_FILE_MODEL}" ] ; then
	rm -rf "${DYNAMIC_FILE_MODEL}"
fi
mkdir -p "${DYNAMIC_FILE_MODEL}"
if [ -d "${DYNAMIC_MAP_MODEL}" ] ; then
	rm -rf "${DYNAMIC_MAP_MODEL}"
fi
mkdir -p "${DYNAMIC_MAP_MODEL}"

if [ -d "${COMBINED_RESULT}" ] ; then
	rm -f ${COMBINED_RESULT}/*
else
        mkdir -p "${COMBINED_RESULT}"
fi

if [ -d "${COMBINED_FILE_MODEL}" ] ; then
	rm -rf "${COMBINED_FILE_MODEL}"
fi
mkdir -p "${COMBINED_FILE_MODEL}"
if [ -d "${COMBINED_MAP_MODEL}" ] ; then
	rm -rf "${COMBINED_MAP_MODEL}"
fi
mkdir -p "${COMBINED_MAP_MODEL}"

echo "------------------------------------------------"
echo "Uvic"
echo "------------------------------------------------"

echo "Preprocess static log to fill in callee file names"
$PREPROCESS -i "${STATIC_LOG}" -m "${STATIC_FUNCTION_MAP}" "${ADDITIONAL_FUNCTION_MAP}" -o "${STATIC_LOG_CORRECTED}"

export CREATE_ARCHITECTURE_MODEL_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.groovy"

echo ""
echo "** File Mode **"
echo "Analysis kieker log ${KIEKER_LOG}"
$ANALYSIS -m kieker -i "${KIEKER_LOG}" -o "${DYNAMIC_RESULT}" -a "${ADDR2LINE}" -e "${EXECUTABLE}" -oa "${DYNAMIC_FILE_MODEL}" -l dynamic -E UVic -c -g dot-component

echo ""
echo "Analysis the corrected static caller-callee log ${STATIC_LOG_CORRECTED}"
$ANALYSIS -m csv -i "${STATIC_LOG_CORRECTED}" -o "${COMBINED_RESULT}" -ia "${DYNAMIC_FILE_MODEL}" -oa "${COMBINED_FILE_MODEL}" -l static -E UVic -H $HOST -c -g dot-component

echo ""
echo "** Map Mode **"
echo "Analysis kieker log ${KIEKER_LOG}"
$ANALYSIS -m kieker -i "${KIEKER_LOG}" -o "${DYNAMIC_RESULT}" -a "${ADDR2LINE}" -e "${EXECUTABLE}" -oa "${DYNAMIC_MAP_MODEL}" -l dynamic -E UVic -c -M "${STATIC_MODULE_MAP}" -g dot-component

echo ""
echo "Analysis the corrected static caller-callee log ${STATIC_LOG_CORRECTED}"
$ANALYSIS -m csv -i "${STATIC_LOG_CORRECTED}" -o "${COMBINED_RESULT}" -ia "${DYNAMIC_MAP_MODEL}" -oa "${COMBINED_MAP_MODEL}" -l static -E UVic -H $HOST -c -M "${STATIC_MODULE_MAP}" -g dot-component

echo ""
echo "Done"
echo ""

# end
