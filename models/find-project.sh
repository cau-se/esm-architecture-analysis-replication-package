#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/../common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
fi

information "${OPTIMIZATION_DATA}"

for I in `find "${OPTIMIZATION_DATA}" -name "type-model.xmi"` ; do
	DIR=`dirname $I`
	if [ ! -f "${DIR}/.project" ] ; then
		basename $DIR
	else
		warning "Missing .project in $DIR"
	fi
done

# end

