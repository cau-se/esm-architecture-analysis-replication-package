#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ ! -f "$1" ] ; then
	echo "Cannot find project list in $1"
	exit 1
else
	LIST="$1"
fi

for I in `cat $LIST` ; do
        $BASE_DIR/run-architecture-analysis.sh "$I"
done

# end

