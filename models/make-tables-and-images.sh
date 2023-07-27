#!/bin/bash

export BASE_DIR=$(cd "$(dirname "$0")"; pwd)

. "${BASE_DIR}/common-functions.rc"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
fi

export JAVA_OPTS="-Dlogback.configurationFile=${BASE_DIR}/logback.xml"

export JOB_FILE="${OPTIMIZATION_DATA}/list-of-tables-and-images.md"

checkDirectory "Result directory" "${OPTIMIZATION_DATA}"
checkFile "List of jobs" "${JOB_FILE}"

IFS=$'\n'

MODE="base"

for LINE in `cat "${JOB_FILE}"` ; do
	if [ $MODE == "base" ] ; then
		information $LINE
		JOB_DIRECTORY="${OPTIMIZATION_DATA}/$LINE.job"
		NAME=$LINE
		MODE="option"
	elif [ $MODE == "option" ] ; then
		FIRST_CHAR=`echo $LINE | sed 's/^\(.\).*$/\1/g'`
		if [ "$FIRST_CHAR" == "-" ] ; then
			OPT=`echo $LINE | sed 's/^- opt-//g'`
			TABLE_CSV="${JOB_DIRECTORY}/original-model-optimized-$OPT.csv"
			information "  $OPT"
			checkFile "diff file" "${TABLE_CSV}"
			MERGE_MODEL="${JOB_DIRECTORY}/original-model-optimized-$OPT"
			mkdir -p "${MERGE_MODEL}"
			${MOP} -e merged-$OPT-$NAME  -i "${JOB_DIRECTORY}/original-model" "${JOB_DIRECTORY}/optimized-$OPT" -o "${MERGE_MODEL}" nearest-merge

			LEFT=""
			RIGHT="optimized-$OPT"
			for E in `cat "${MERGE_MODEL}/source-model.xmi" | grep "<value>" | sort | uniq | sed 's/^ *<value>\(.*\)<\/value>$/\1/g' | grep -v "optimized-$OPT"` ; do
				if [ "${LEFT}" == "" ] ; then
					LEFT=$E
				else
					LEFT="$LEFT,$E"
				fi
			done

			${MKTABLE} -i "${MERGE_MODEL}.csv" -o "${MERGE_MODEL}"
			LAST_PWD=`pwd`
			cd "${MERGE_MODEL}"
			pdflatex full.tex
			pdflatex compact.tex
			cd $LAST_PWD
			#${MVIS} -c allen num-of-calls op-coupling module-coupling -g dot-op dot-component -i "${MERGE_MODEL}" -o "${MERGE_MODEL}" -m add-nodes -s "all-color:$LEFT:$RIGHT"
			#${BASE_DIR}/dotPic-single-fileConverter.sh "${MERGE_MODEL}/original-model-optimized-$OPT-component.dot" pdf &
			#${BASE_DIR}/dotPic-single-fileConverter.sh "${MERGE_MODEL}/original-model-optimized-$OPT-operation.dot" pdf &
		else
			information $LINE
			JOB_DIRECTORY="${OPTIMIZATION_DATA}/$LINE.job"
			NAME=$LINE
		fi
	fi
done

# end
