#!/bin/bash

# Execute R based statistics on a set of projects

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -f "$1" ] ; then
	PROJECTS="$1"
else
	echo "run-statistics.sh <project-list.lst>"
	exit
fi

for EXPERIMENT in `cat "$PROJECTS"` ; do
        R --no-restore -q -s  --file=statistics.r --args "${EXPERIMENT}" | grep -v '^> ' | grep -v '^+' | cut -c5- | sed 's/"//g'
done

# end
