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

# variables
export MITGCM_DATA_PATH="${DATA_PATH}/mitgcm/${EXPERIMENT_NAME}"

STATIC_FILE_MODEL="${MITGCM_DATA_PATH}/static/file"
STATIC_MAP_MODEL="${MITGCM_DATA_PATH}/static/map"
STATIC_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/static/2-level"

IFACE_STATIC_FILE_MODEL="${MITGCM_DATA_PATH}/static/iface-file"
IFACE_STATIC_MAP_MODEL="${MITGCM_DATA_PATH}/static/iface-map"
IFACE_STATIC_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/static/iface-2-level"

DYNAMIC_FILE_MODEL="${MITGCM_DATA_PATH}/dynamic/file"
DYNAMIC_MAP_MODEL="${MITGCM_DATA_PATH}/dynamic/map"
DYNAMIC_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/dynamic/2-level"

IFACE_DYNAMIC_FILE_MODEL="${MITGCM_DATA_PATH}/dynamic/iface-file"
IFACE_DYNAMIC_MAP_MODEL="${MITGCM_DATA_PATH}/dynamic/iface-map"
IFACE_DYNAMIC_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/dynamic/iface-2-level"

COMBINED_FILE_MODEL="${MITGCM_DATA_PATH}/combined/file"
COMBINED_MAP_MODEL="${MITGCM_DATA_PATH}/combined/map"
COMBINED_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/combined/2-level"

IFACE_COMBINED_FILE_MODEL="${MITGCM_DATA_PATH}/combined/iface-file"
IFACE_COMBINED_MAP_MODEL="${MITGCM_DATA_PATH}/combined/iface-map"
IFACE_COMBINED_2_LEVEL_MODEL="${MITGCM_DATA_PATH}/combined/iface-2-level"



# check tools
checkExecutable "Model visualizations" "${MVIS}"

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

checkDirectory "Combined file model" "${COMBINED_FILE_MODEL}"
checkDirectory "Combined map model" "${COMBINED_MAP_MODEL}"
checkDirectory "Combined 2-level model" "${COMBINED_2_LEVEL_MODEL}"

checkDirectory "Combined iface file model" "${IFACE_COMBINED_FILE_MODEL}"
checkDirectory "Combined iface map model" "${IFACE_COMBINED_MAP_MODEL}"
checkDirectory "Combined iface 2-level model" "${IFACE_COMBINED_2_LEVEL_MODEL}"

# check outputs


# run
TEMPFILE=`mktemp`
cat << EOF > $TEMPFILE
${DYNAMIC_FILE_MODEL}
${DYNAMIC_MAP_MODEL}
${DYNAMIC_2_LEVEL_MODEL}
${IFACE_DYNAMIC_FILE_MODEL}
${IFACE_DYNAMIC_MAP_MODEL}
${IFACE_DYNAMIC_2_LEVEL_MODEL}
${STATIC_FILE_MODEL}
${STATIC_MAP_MODEL}
${STATIC_2_LEVEL_MODEL}
${IFACE_STATIC_FILE_MODEL}
${IFACE_STATIC_MAP_MODEL}
${IFACE_STATIC_2_LEVEL_MODEL}
${COMBINED_FILE_MODEL}
${COMBINED_MAP_MODEL}
${COMBINED_2_LEVEL_MODEL}
${IFACE_COMBINED_FILE_MODEL}
${IFACE_COMBINED_MAP_MODEL}
${IFACE_COMBINED_2_LEVEL_MODEL}
EOF

information "Compute file level statistics"
IFS=$'\n'
for I in `cat $TEMPFILE` ; do
	"${MVIS}" -i "$I" -o "$I" -s all -g dot-op dot-component -c -m add-nodes
done

# end
