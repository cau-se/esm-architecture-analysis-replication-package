#!/bin/bash

RESTRUCTURING="/home/reiner/temp/experiment/install/oceandsl-tools/bin/restructuring"

DATA="/home/reiner/jss-results/jss-jobs-22-mitgcm_tutorial_barotropic_gyre_combined_iface-map.job"
ORIGINAL="${DATA}/original-model"

"${RESTRUCTURING}" -i "${ORIGINAL}" "${DATA}/optimized-"* -o "${DATA}" -e demo -s normal

# end
