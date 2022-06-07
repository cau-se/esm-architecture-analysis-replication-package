#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)

export MODEL_LOCATION="$1"
export INPUT_DIR="$2"

if [ ! -x "${MODEL_LOCATION}" ] ; then
	echo "Model not found: ${MODEL_LOCATION}"
	exit 1
fi

if [ "${INPUT_DIR}" == "" ] ; then
	echo "Missing input directory."
	exit 1
elif [ ! -d "${INPUT_DIR}" ] ; then
	echo "Path is not a directory: ${INPUT_DIR}"
	exit 1
elif [ ! -f "${INPUT_DIR}/kieker.map" ] ; then
	echo "Path is not a proper Kieker log folder, missing map file: ${INPUT_DIR}"
	exit 1
fi

# cleanup
rm -f /tmp/locations /tmp/map-file

# scan all logged messages from Kieker
cat $INPUT_DIR/kieker-*dat | grep '^$[23]' | sed 's/.*;\(0x[0-9a-f]*\);.*/\1/g' | sort | uniq > /tmp/locations

# process locations
touch /tmp/map-file
for I in `cat /tmp/locations` ; do
#	R=`addr2line -e "$MODEL_LOCATION" -p -C -s -f $I`
	R=`addr2line -e "$MODEL_LOCATION" -p -C -f $I`
	F=`echo $R | awk '{ print $1 }'`
	C_PATH=`echo $R | awk '{ print $3 }' | sed 's/^\(.*\/\w*\)\.f:[0-9]*$/\1/g'`
	if [ -L "${C_PATH}.F" ] ; then
		C=`realpath "${C_PATH}.F" | sed 's/.*\/pkg\/\(\w*\)\/.*/\1/g'`
		D=`realpath "${C_PATH}.F"`
		if [ "$C" == "$D" ] ; then
			C="BASE"
		fi
	fi
	echo "$I#$C#$F" >> /tmp/map-file
done

for J in `cat /tmp/map-file` ; do
	ID=`echo $J | cut -d'#' -f1`
	COMPONENT=`echo $J | cut -d'#' -f2`
	FUNCTION=`echo $J | cut -d'#' -f3`

	echo "id: $ID  component: $COMPONENT  function: $FUNCTION"

	for I in $INPUT_DIR/kieker-*dat ; do
		if [ -f "$I.new" ] ; then
			mv "$I.new" "$I.old"
			cat "$I.old" | sed "s/$ID;<package structure>/$FUNCTION;$COMPONENT/g" > "$I.new"
		else
			cat "$I" | sed "s/$ID;<package structure>/$FUNCTION;$COMPONENT/g" > "$I.new"
		fi
	done
done

# cleanup
for I in $INPUT_DIR/kieker-*dat.new ; do
	J=`echo $I | sed 's/dat\.new$/dat/g'`
	mv "$I" "$J"
done

rm -f /tmp/locations /tmp/map-file

# end
