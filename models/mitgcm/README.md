# ECSA MITgcm - Setup

This archive contains the instructions to setup and execute all
experiments we performed with MITgcm. Please note that we performed
all our experiments on Linux machines running Ubuntu 20.04 and Debian
Buster on AMD64/Intel 64 bit CPUs.

## Prerequisites

- MITgcm
  - Linux build tools, including gcc, gfortran, make, autoconf, automake
    and libtool
  - Netcdf library including development files
  - Additional information in the MITgcm documentation
    https://mitgcm.readthedocs.io/en/latest/getting_started/getting_started.html
- OceanDSL tooling
  - Java 11 OpenJDK or compatible including the JDK
  - Download the Kieker binary distribution
    `https://kieker-monitoring.net/download/`
- Other
  - Git
  - Bash
- Follow the installation instructions in the global README.md

## Preparations

We assume that you have read the setup instructions in the main README.md and
that you follow the directory layout discussed there. In case you have chosen
another structure, please adapt directories accordingly.

Please note that the ${REPLICATION_DIR} is the main directory of the whole
setup and ${SCRIPTS_DIR} is the directory of this README.md file, e.g.,
`${REPLICATION_DIR}/esm-architecture-analysis-replication-package/models/mitgcm`
and the ${GLOBAL_SCRIPTS_DIR} is the directory one level up, e.g., 
`${REPLICATION_DIR}/esm-architecture-analysis-replication-package/models`.

Create a workspace directory for the analyis, e.g., `experiments/mitgcm`, and
switch to this directory.
```
cd ${REPLICATION_DIR}
mkdir -p experients/mitgcm
cd experiments/mitgcm
```

Clone the *mitgcm* repository.
```
git clone https://github.com/MITgcm/MITgcm.git
```

## Test MITgcm 

MITgcm comes with a large set of preconfigured setups fro experiments.
Usually they run out of the box. If this fails, you must fix these
issues first before continuing with the experiment setup. To test
your setup perform the following steps:

Change to a *mitgcm* experiment directory.
```
cd MITgcm/verification/tutorial_barotropic_gyre
```
This is one of the simple experiments and the first in the tutorial
section of their documentation. Follow their build instructions
listed in the README.

Here is a copy of the basic steps.

Configure and compile the code:
```
  cd build
  ../../../tools/genmake2 -mods ../code [-of my_platform_optionFile]
  make depend
  make
  cd ..
```

To run:
```
  cd run
  ln -s ../input/* .
  ln -s ../build/mitgcmuv .
  ./mitgcmuv > output.txt
  cd ..
```

You should check the `output.txt` file for errors.

If all works well, go back to the `experiments/mitgcm` directory, e.g.,
```
cd ../..
```

## Setting up the Experiments

Switch to the `${GLOBAL_SCRIPTS_DIR}` directory.

Here you need to create a `config` file in the `${GLOBAL_SCRIPT_DIR}`.
You can use the `config.template` in the same directory as template. 

Then the configuration file should look like this:
```
# Main replication directory
export REPLICATION_DIR="/home/user/replication"

# Library path including Kieker libraries
export KIEKER_LIBRARY_PATH="${REPLICATION_DIR}/../kieker/lib/"

# Location for dynamic and static data
export DATA_PATH="${REPLICATION_DIR}/data"

# List of external functions
export EXTERNAL_FUNCTIONS_MAP="${REPLICATION_DIR}/builtin-functions.csv"
export STATIC_AUX_MODULE_MAP="${REPLICATION_DIR}/uvic-aux-map-file.csv"

export TOOL_DIR="${REPLICATION_DIR}"

# Data directory for results from the optimization
OPTIMIZATION_DATA="/home/user/restructuring-results"

DAR="${TOOL_DIR}/oceandsl-tools/bin/dar"
SAR="${TOOL_DIR}/oceandsl-tools/bin/sar"
MAA="${TOOL_DIR}/oceandsl-tools/bin/maa"
MOP="${TOOL_DIR}/oceandsl-tools/bin/mop"
MVIS="${TOOL_DIR}/oceandsl-tools/bin/mvis"
RELABEL="${TOOL_DIR}/oceandsl-tools/bin/relabel"
FXCA="${TOOL_DIR}/oceandsl-tools/bin/fxca"
FXTRAN="${TOOL_DIR}/fxtran"
RESTRUCTURING="${TOOL_DIR}/oceandsl-tools/bin/restructuring"
DELTA="${TOOL_DIR}/oceandsl-tools/bin/delta"
MKTABLE="${TOOL_DIR}/oceandsl-tools/bin/mktable"

# collector tool
COLLECTOR="${TOOL_DIR}/collector/bin/collector"

# addr2line
ADDR2LINE=`which addr2line`

# Hostname where the dynamic analysis was executed
HOST=glasgow
```

Of course the HOST variable must be changed to the name of the machine
the experiments are run. As this is the global configuration file, you
must also setup the second config file for mitgcm.

```
cd "${SCRIPTS_DIR}"
cp config.template config
```

Then edit the config file accordingly.

The next file you have to create is a list of all experiments you want
to run. The file must be named `experiments`. A list of all experiments
which are used in the tutorial of MITgcm are listed in `tutorials` and
all other experiments are listed in `normal`. 

## Selecting models

Mitgcm comes with multiple prepared experiments located in the `verification`
subdirectory. You can run any number of these experiments following the
instructions below. For certain experiments additional setup is required.
Information for these experiments can be found in the respective
experiment directory.

## Dynamic Observations

To run a single experiment type
```
cd ${SCRIPTS_DIR}
./run-dynamic-observation.sh tutorial_barotropic_gyre
```
where `tutorial_barotropic_gyre` is the experiment to be executed.

**Note:** This will automatically create a new experiments file with 
`tutorial_barotropic_gyre` as only entry.

You can run all experiments from the verification directory of mitgcm.
However, some need additional setup and the experiment may not run as
intended. These experiments have additional instructions which
can be found in the respective experiment folder.

You also may want to increase the runtime of certain experiments, to
ensure that all parts of the experiment are used. Such instructions
can also be found in the respecticve experiment directory and online
at `https://mitgcm.readthedocs.io/en/latest/examples/examples.html`.

## Static Code Processing

Fortran code may use built-in functions. There have to be registered
in a function map. Copy from

```
cp "${REPLICATION_DIR}/esm-architecture-analysis-replication-package/models/builtin-functions.csv" "${REPLICATION_DIR}"
```

Run the code processing with

```
cd "${SCRIPTS_DIR}"
./run-static-code-processing.sh tutorial_barotropic_gyre
```

## Architecture Reconstruction

Lets assume you have collected the dynamic and static data for a MITgcm
experiment, e.g., `tutorial_barotropic_gyre`. Ensure that you are in the
`${SCRIPTS_DIR}` directory.

```
cd "${SCRIPTS_DIR}"
./run-static-analysis.sh tutorial_barotropic_gyre call
./run-dynamic-analysis.sh tutorial_barotropic_gyre
```
Instead of `call` the static analysis also accepts `dataflow` and `both`
as parameters. 

## Automation of Analysis

Instead of running the scripts above, you can automate this with

```
cd "${GLOBAL_SCRIPTS_DIR}"
./run-architecture-analysis.sh tutorial_barotropic_gyre mitgcm
```

This call runs all dynamic and static analysis steps for the specified
variant - here `tutorial_barotropic_gyre` for the model `mitgcm`.

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

## Run all experiments

You can use `./run-all-analysis.sh ${experiments}.lst` to run all
experiment architecture analyses automatically.
We have prepared two lists
- `all-variants.lst` contains all variants of mitgcm
- `normal-variants.lst` are variants that do not require additional setup

## Visualization

You can use the `dotPic-fileConverter.sh` from the Kieker archive to
convert all dot files. This tool requires `dot` installed on your
machine.

Alternatively, you can use from the Kieker Development Tools the visualization
component. These are a bundle of tools used with Kieker and are implemented
as plugins for Eclipse. The Eclipse repository is

`https://maui.se.informatik.uni-kiel.de/repo/kdt/snapshot/`



