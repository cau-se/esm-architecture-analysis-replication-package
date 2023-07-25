#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../common-functions.rc"

if [ "$1" != "" ] ; then
	EXPERIMENT_NAME="$1"
else
	echo "Missing mitgcm variant"
	exit 1
fi

if [ -f "${BASE_DIR}/../config" ] ; then
        . "${BASE_DIR}/../config"
else
        echo "Main config file not found."
        exit 1
fi
if [ -f "$BASE_DIR/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Config file not found."
        exit 1
fi

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/../logback.xml"
export MODEL_DATA_PATH="${DATA_PATH}/mitgcm/${EXPERIMENT_NAME}"

# inputs
checkDirectory "Static data" "${MODEL_DATA_PATH}" create
checkDirectoryList "Source directory" "${SOURCE_CODE_PATH}"
checkDirectory "Processed source directory" "${PROCESSED_CODE_PATH}"
checkFile "External functions map" "${EXTERNAL_FUNCTIONS_MAP}"
checkExecutable "fxtran" "${FXTRAN}"
checkExecutable "fxca" "${FXCA}"

# outputs
STATIC_COMPONENT_MAP="${MODEL_DATA_PATH}/module-file-map.csv"

information "Create directory/file map"

echo "module;file" > "${STATIC_COMPONENT_MAP}"

for EXT in f f90 f95 ; do
	for SINGLE_PATH in `echo "${SOURCE_CODE_PATH}" | tr ":" "\n"` ; do
	 	for I in `find "${SINGLE_PATH}" -iname "*.$EXT" -printf "%P\n"` ; do
			ENTRY=`echo $I | sed 's/\/\([0-9A-Za-z\-_.]*\)/;\1/' | sed 's/F\([0-9]*\)$/f\1/'`
			if [[ "$ENTRY" =~ .*";".* ]]; then
				echo "$ENTRY" >> "${STATIC_COMPONENT_MAP}"
			else
				BASENAME=`basename "${SINGLE_PATH}"`
				echo "$BASENAME;$ENTRY" >> "${STATIC_COMPONENT_MAP}"
			fi
		done
	done
done

information "Parse processed code"

CURRENT_PATH=`pwd`
cd "${PROCESSED_CODE_PATH}"

../../../tools/genmake2 -mods ../code
make depend
make

information "Parse processed code"

for I in `find . -name "*.f"` ; do
	"${FXTRAN}" "$I"
done
cd "${CURRENT_PATH}"

${FXCA} -i "${PROCESSED_CODE_PATH}" -o "${MODEL_DATA_PATH}" -l "${EXTERNAL_FUNCTIONS_MAP}"

# end
