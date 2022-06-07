#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -f "$BASE_DIR/config" ] ; then
        . $BASE_DIR/config
else
        echo "Config file not found."
        exit 1
fi

export DATA_PATH=${DATA_PATH//\//\\/}

cd "${PREFIX}"

if [ "$1" != "" ] ; then
	echo "$1" > $BASE_DIR/tutorials
else
cat << EOF > $BASE_DIR/tutorials
tutorial_advection_in_gyre
tutorial_baroclinic_gyre
tutorial_barotropic_gyre
tutorial_cfc_offline
tutorial_deep_convection
tutorial_dic_adjoffline
tutorial_global_oce_biogeo
tutorial_global_oce_in_p
tutorial_global_oce_latlon
tutorial_global_oce_optim
tutorial_held_suarez_cs
tutorial_plume_on_slope
tutorial_reentrant_channel
tutorial_rotating_tank
EOF
fi

# tutorial_tracer_adjsens

for I in `cat $BASE_DIR/tutorials` ; do
	# start collector
	echo "Starting collector"
	cat $BASE_DIR/collector.conf.template | sed "s/%EXPERIMENT%/$I/g" | sed "s/%DATA_PATH%/$DATA_PATH/g" > $BASE_DIR/collector.conf
	$BASE_DIR/collector-1.15-SNAPSHOT/bin/collector -c $BASE_DIR/collector.conf &
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

rm $BASE_DIR/tutorials

# end

