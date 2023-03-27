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

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.groovy"

"${BASE_DIR}/run-static-code-processing.sh" "${EXPERIMENT_NAME}"
"${BASE_DIR}/run-static-analysis.sh" "${EXPERIMENT_NAME}"
"${BASE_DIR}/run-dynamic-observation.sh" "${EXPERIMENT_NAME}"
"${BASE_DIR}/run-dynamic-analysis.sh" "${EXPERIMENT_NAME}"

"${BASE_DIR}/combine-models.sh" "${EXPERIMENT_NAME}"
"${BASE_DIR}/compute-statistics.sh" "${EXPERIMENT_NAME}"

# end
