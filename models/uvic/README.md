# UVic

UVic is a model from the University of Victoria, Canada.

http://terra.seos.uvic.ca/model/

There are also other sources from where you can obtain UVic variants, e.g.,
from the gitlab of GEOMAR.

## Obtaining UVic

For the original code from the University of Victora, you must request
access to the code. However, this should be fairly simple.

Beside the version 2.9.2, they also provide archives of previous versions.

## Preparations

We assume that you have read the setup instructions in the main README.md and
that you follow the directory layout discussed there. In case you have chosen
another structure, please adapt directories accordingly.

Please note that the ${REPLICATION_DIR} is the main directory of the whole
setup and ${SCRIPTS_DIR} is the directory of this README.md file, e.g.,
`${REPLICATION_DIR}/esm-architecture-analysis-replication-package/models/uvic`

Create a workspace directory for the analyis, e.g., `experiments/uvic`, and
switch to this directory.
```
cd ${REPLICATION_DIR}
mkdir -p experients/uvic
cd experiments/uvic
```

## Test UVic

## Setting up the Experiments

To setup the experiments you have to create a config file in the ${SCRIPT_DIR}.
You can use the config.template as a starting point. The variable $NAME refers
to the experiment name and $VERSION to the version directory name.
When using git repositories, different version may be held in different
branches. In that case the repository path must just point to the git repository
and the $VERSION variable must contain the branch or tag name.

```
# Base directory of your replication efforts
export REPLICATION_DIR="/home/reiner/temp/exp"

# Library path including Kieker libraries
export KIEKER_LIBRARY_PATH="${REPLICATION_DIR}/km/lib/"

# Location for dynamic and static data
export DYNAMIC_DATA_PATH="${REPLICATION_DIR}/experiments/uvic/dynamic-data"
export STATIC_DATA_PATH="${REPLICATION_DIR}/experiments/uvic/static-data"

DAR="${REPLICATION_DIR}/oceandsl-tools/bin/dar"
SAR="${REPLICATION_DIR}/oceandsl-tools/bin/sar"
MAA="${REPLICATION_DIR}/oceandsl-tools/bin/maa"
MOP="${REPLICATION_DIR}/oceandsl-tools/bin/mop"
MVIS="${REPLICATION_DIR}/oceandsl-tools/bin/mvis"

# collector tool
COLLECTOR="${REPLICATION_DIR}/collector/bin/collector"

# addr2line
ADDR2LINE=`which addr2line`

# Path to uvic repository
REPOSITORY_DIR="${REPLICATION_DIR}/experiments/uvic/$VERSION"
# Compile configurtion for kieker
export CONFIGURATION="${REPOSITORY_DIR}/run/mk.in"
# Path to the executable
EXECUTABLE="${REPOSITORY_DIR}/UVic_ESCM"


# Dynamic and static prefix
DYNAMIC_PREFIX="$PREFIX/$NAME/build/"
STATIC_PREFIX="/home/hschnoor/eclipse-workspace/PlayPython/resources/preprocessed/MITgcm-$NAME/"

# Hostname where the dynamic analysis was executed
HOST=glasgow
```

## Dynamic Analysis

**Note:** For test purposes, it is helpful run the data collection with
one experiment only.

To run a single experiment you can type
```
cd ${SCRIPTS_DIR}
./run-dynamic-observation.sh uvic-2.9.2
```
where `uvic-2.9.2` is the experiment to be executed.

**Note:** This will automatically create a new experiments file with
`uvic-2.9.2` as only entry.

## Static Analysis

-- added here -- TODO (hs)

## Architecture Reconstruction

Lets assume you have collected the dynamic and static data for a MITgcm
experiment, e.g., `uvic-2.9.2` and you are in the
`${REPLICATION_DIR}/experiments/uvic` directory. Now you can run the analysis
for the experiment with

`./run-architecture-analysis.sh uvic-2.9.2`

If everything is setup properly, you will get results files for the
various analyses:
- `dynamic-result` contains CSV files for various graphs of the
  architecture model and dot files for the operation and component
  view of the analysis. A graphml file is also generated. The files
  follow a naming scheme EXPERIMENT-TYPE-CONTENT.EXTENSION where:
  - EXPERIMENT is the name of the experiment
  - TYPE is either *file* for each file is seen as a module or component
    or *map* using a map file to group operations/files to modules. 
  - CONTENT describes what the file contains, e.g.,
    `dynamic-distinct-function-degree`.
  - EXTENSION refers to the proper file-type extension, e.g., csv.
- `dynamic-model` contains for each experiment two subfolders for
   *file* and *map* based architecture. Each folder contains an dump
   of the internal architectural model as a set of XMI files.
- `combined-result` contains the same files as the `dynamic-result but
  now also the data from the static analysis has been used.
- `combined-model` similar to `dynamic-model`, but these models reflect
  the architecture after the dynamic and static analysis. 


## Additional Information


