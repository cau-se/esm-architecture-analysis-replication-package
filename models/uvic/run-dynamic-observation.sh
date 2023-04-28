#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Config file not found."
        exit 1
fi

export MODEL_DATA_PATH="${DATA_PATH}/uvic"

export COLLECTOR_DATA_PATH=${MODEL_DATA_PATH//\//\\/}

cd "${REPOSITORY_DIR}"

CURRENT_DIR=`pwd`

export CONFIGURATION="${REPOSITORY_DIR}/run/mk.in"
export EXECUTABLE="${REPOSITORY_DIR}/run/UVic_ESCM"
export MK_SCRIPT="${REPOSITORY_DIR}/../mk"

# inputs
checkDirectory "uvic-version" "${REPOSITORY_DIR}"
checkFile "uvic-configuration" "${CONFIGURATION}"
checkExecutable "mk-script" "${MK_SCRIPT}"

# start collector
echo "Starting collector"
cat "${BASE_DIR}/collector.conf.template" | sed "s/%EXPERIMENT%/$I/g" | sed "s/%DATA_PATH%/${COLLECTOR_DATA_PATH}\/$I/g" > "${BASE_DIR}/collector.conf"

"${COLLECTOR}" -c "${BASE_DIR}/collector.conf" &
export COLLECTOR_PID=$!

# wait for the collector to come up
information "Wait for startup"
sleep 10

# configure uvic
information "Configure UVic"
cd "${REPOSITORY_DIR}"
cp "${CONFIGURATION}" "${CONFIGURATION}.factory"

cat << EOF >> "${CONFIGURATION}"
# code directory
Version_Directory = ${SOURCE_CODE_PATH}
# compile setting
Libraries = -lnetcdf -lnetcdff -lkieker -L/usr/lib/x86_64-linux-gnu -L${KIEKER_LIBRARY_PATH}

Compiler_F = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Compiler_f = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Compiler_F90 = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Compiler_f90 = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Linker = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -o
EOF

# compile
information "Compile UVic"
cd run

${MK_SCRIPT} c
${MK_SCRIPT} e

# run uvic
information "Run UVic"
if [ -x "${EXECUTABLE}" ] ; then
	"${EXECUTABLE}" &> UVic.log
else
	error "No UVic_ESCM found as ${EXECUTABLE}."
fi

# end experiment
information "Wait for collector to shutdown $COLLECTOR_PID"
kill -TERM $COLLECTOR_PID
wait $COLLECTOR_PID

mv "${CONFIGURATION}.factory" "${CONFIGURATION}"

cd "${CURRENT_DIR}"

# end
