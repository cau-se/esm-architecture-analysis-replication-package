#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)
EXPERIMENTS="${BASE_DIR}/experiments"

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

export DATA_PATH=${DATA_PATH//\//\\/}

cd "${PREFIX}"

if [ "$1" != "" ] ; then
	echo "$1" > "${EXPERIMENTS}"
else
	if [ ! -f "${EXPERIMENTS}" ] ; then
		echo "Missing experiments file"
		exit 1
	fi
fi

for I in `cat "${EXPERIMENTS}"` ; do
	# start collector
	echo "Starting collector"
	cat $BASE_DIR/collector.conf.template | sed "s/%EXPERIMENT%/$I/g" | sed "s/%DATA_PATH%/$DATA_PATH/g" > $BASE_DIR/collector.conf
	"${COLLECTOR}" -c "${BASE_DIR}/collector.conf" &
	export COLLECTOR_PID=$!

	# wait for the collector to come up
	echo "Wait for startup"
	sleep 30

        # build experiment
        echo "Build experiment"
	if [ -x "${PREFIX}/$I/build.sh" ] ; then
	        cd "${PREFIX}/$I/build"
		rm -r *
		"${PREFIX}/$I/build.sh"
		cd ..
	else
	        cd "${PREFIX}/$I/build"
		rm -r *
	        ../../../tools/genmake2 -mods ../code -of "${CONFIGURATION}"
		make clean
        	make depend
        	make
        	cd ..
	fi
	# run experiment
	echo "Run experiment"
        if [ -x "${PREFIX}/$I/run.sh" ] ; then
		cd "${PREFIX}/$I/run"
		rm -r *
		"${PREFIX}/$I/run.sh"
		cd ..
	else
		cd "${PREFIX}/$I/run"
		rm -r *
	        ln -s ../input/* .
        	ln -s ../build/mitgcmuv .
		./mitgcmuv > /dev/null
		rm -r *
		cd ..
	fi

	# end experiment
	echo "Wait for collector to shutdown $COLLECTOR_PID"
	kill -TERM $COLLECTOR_PID
	wait $COLLECTOR_PID
done

# end

