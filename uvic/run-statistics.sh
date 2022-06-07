#!/bin/bash

EXPERIMENT="UVic"
LOCATIONS="dynamic-result combined-result"
TYPES="file map"

for LOCATION in $LOCATIONS ; do
        for TYPE in $TYPES ; do
                R --no-restore -q -s  --file=statistics.r --args "${EXPERIMENT}" "${LOCATION}" "${TYPE}" | grep -v '^> ' | grep -v '^+' | cut -c5- | sed 's/"//g'
        done
done
# end
