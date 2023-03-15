#!/bin/bash

SOURCE_DIR="$1"
TARGET_DIR="$2"

MAP_FILE="uvic-map-file.csv"

rm -f "${MAP_FILE}"

for EXT in f f90 f95 ; do
	for I in `find "${SOURCE_DIR}" -iname "*.$EXT" -printf "%P\n"` ; do
		echo $I	| sed 's/\/\([0-9A-Za-z\-_.]*\)/;\1/' >> "${MAP_FILE}"
	done
done

# end


