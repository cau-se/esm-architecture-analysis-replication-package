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

export MODEL_DATA_PATH="${DATA_PATH}/mitgcm/${EXPERIMENT_NAME}"

export COLLECTOR_DATA_PATH=${MODEL_DATA_PATH//\//\\/}

# inputs
checkDirectory "Dynamic data" "${MODEL_DATA_PATH}" create

# start collector
echo "Starting collector"
cat "${BASE_DIR}/collector.conf.template" | sed "s/%EXPERIMENT%/$I/g" | sed "s/%DATA_PATH%/${COLLECTOR_DATA_PATH}\/$I/g" > "${BASE_DIR}/collector.conf"

"${COLLECTOR}" -c "${BASE_DIR}/collector.conf" &
export COLLECTOR_PID=$!

# wait for the collector to come up
information "Wait for startup"
sleep 10

# configure mitgcm
information "Configure MITgcm"
export CURRENT_DIR=`pwd`
cd "${PROCESSED_CODE_PATH}"

../../../tools/genmake2 -mods ../code -of "${CONFIGURATION}" &> genmake.log
make depend >& makedepend.log

# compile
information "Compile MITgcm ${EXPERIMENT_NAME}"

make >& makefile.log

cd ..

# run mitgcm
information "Run MITgcm"
if [ -x "${EXECUTABLE}" ] ; then
	cd run
	if [ -x "${BASE_DIR}/runscript-${EXPERIMENT_NAME}.rc" ] ; then
		. "${BASE_DIR}/runscript-${EXPERIMENT_NAME}.rc"
	else
		ln -s ../input/* .
		ln -s ../build/mitgcmuv .
	fi
	./mitgcmuv &> mitgcm.log
else
	error "No MITgcm found as ${EXECUTABLE}."
fi

# end experiment
information "Wait for collector to shutdown $COLLECTOR_PID"
kill -TERM $COLLECTOR_PID
wait $COLLECTOR_PID

cd "${CURRENT_DIR}"

# end
