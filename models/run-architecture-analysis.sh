#!/bin/bash

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

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

information "++++++++++++++++++++++++++++++++++++++"
information "Configuration ${EXPERIMENT_NAME}"
information "++++++++++++++++++++++++++++++++++++++"

"${BASE_DIR}/$MODEL/run-static-code-processing.sh" "${EXPERIMENT_NAME}"
"${BASE_DIR}/$MODEL/run-static-analysis.sh" "${EXPERIMENT_NAME}" call
"${BASE_DIR}/$MODEL/run-static-analysis.sh" "${EXPERIMENT_NAME}" dataflow
"${BASE_DIR}/$MODEL/run-static-analysis.sh" "${EXPERIMENT_NAME}" both

"${BASE_DIR}/$MODEL/run-dynamic-observation.sh" "${EXPERIMENT_NAME}"
"${BASE_DIR}/$MODEL/run-dynamic-analysis.sh" "${EXPERIMENT_NAME}"

for I in call dataflow both ; do
	"${BASE_DIR}/combine-models.sh" "${EXPERIMENT_NAME}" "$MODEL" "$I"
	"${BASE_DIR}/compute-statistics.sh" "${EXPERIMENT_NAME}" "$MODEL" "$I"
done

information "++++++++++++++++++++++++++++++++++++++"
information "Done ${EXPERIMENT_NAME}"
information "++++++++++++++++++++++++++++++++++++++"

# end
