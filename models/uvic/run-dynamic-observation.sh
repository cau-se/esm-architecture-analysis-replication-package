#!/bin/bash

BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -f "$BASE_DIR/config" ] ; then
        . "${BASE_DIR}/config"
else
        echo "Config file not found."
        exit 1
fi

. "${BASE_DIR}/../../common-functions.rc"

export COLLECTOR_DATA_PATH=${DYNAMIC_DATA_PATH//\//\\/}

cd "${UVIC_REPOSITORY}"

if [ "$1" != "" ] ; then
	echo "$1" > "${BASE_DIR}/experiments"
else
	cat << EOF > "${BASE_DIR}/experiments"
2.6-fixed
2.7-fixed
2.7.1-fixed
2.7.2-fixed
2.7.3-fixed
2.7.4-fixed
2.7.5-fixed
2.8
2.9
2.9.1
2.9.2
EOF
fi

# tutorial_tracer_adjsens

for I in `cat "${BASE_DIR}/experiments"` ; do
	# start collector
	echo "Starting collector $I"
	cat "${BASE_DIR}/collector.conf.template" | sed "s/%EXPERIMENT%/$I/g" | sed "s/%DATA_PATH%/${COLLECTOR_DATA_PATH}\/$I/g" > "${BASE_DIR}/collector.conf"
	rm -rf "${DYNAMIC_DATA_PATH}/$I"
	mkdir -p "${DYNAMIC_DATA_PATH}/$I"
	"${COLLECTOR}" -c "${BASE_DIR}/collector.conf" &
	export COLLECTOR_PID=$!

	# wait for the collector to come up
	information "Wait for startup"
	sleep 10

	# configure uvic
	information "Configure UVic"
	cd "${REPOSITORY_DIR}"
	echo "$I"
	git checkout "$I"
	cat << EOF >> "${CONFIGURATION}"
### miscellaneous settings
Version_Directory = "${REPOSITORY_DIR}"

Executable_File = UVic_ESCM
Input_File = control.in
Output_File = pr
Code_Directory = code
Data_Directory = data
Updates_Level = latest
No_Warnings = true
Preprocessor = fpp
Libraries = -lnetcdf -lnetcdff -lkieker -L/usr/lib/x86_64-linux-gnu -L${KIEKER_LIBRARY}

Compiler_F = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Compiler_f = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Compiler_F90 = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Compiler_f90 = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -c
Linker = ifort -r8 -g -finstrument-functions -O0 -warn nouncalled -o
EOF

	# compile
	information "Compile UVic"
	cd run
	../mk c
	../mk e

	# run uvic
	information "Run UVic"
	./UVic_ESCM &> UVic.log

	cd "${UVIC_REPOSITORY}"

	# end experiment
	information "Wait for collector to shutdown $COLLECTOR_PID"
	kill -TERM $COLLECTOR_PID
	wait $COLLECTOR_PID
done

rm "${BASE_DIR}/experiments"

# end

