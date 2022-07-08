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

Lets assume you are in the `${SCRIPTS}` directory.

Here you need to create a `config` file. You can use the `config.template` that
resides alongside this `README.md`-file.

Then the configuration file should look like this:

```
# PREFIX for the mitgcm model variants
PREFIX="${REPLICATION_DIR}/experiments/mitgcm/MITgcm/verification"

# Library path including Kieker libraries
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${REPLICATION_DIR}/kieker/lib/"

# Compile configurtion for kieker
export CONFIGURATION="${REPLICATION_DIR}/experiments/mitgcm/linux_amd64_gfortran_kieker"

# Location for dynamic and static data
export DYNAMIC_DATA_PATH="${REPLICATION_DIR}/experiments/mitgcm/dynamic-data"
export STATIC_DATA_PATH="${REPLICATION_DIR}/experiments/mitgcm/static-data"

DAR="${REPLICATION_DIR}/oceandsl-tools/bin/dar"
SAR="${REPLICATION_DIR}/oceandsl-tools/bin/sar"
MAA="${REPLICATION_DIR}/oceandsl-tools/bin/maa"
MOP="${REPLICATION_DIR}/oceandsl-tools/bin/mop"
MVIS="${REPLICATION_DIR}/oceandsl-tools/bin/mvis"

# collector tool
COLLECTOR="${REPLICATION_DIR}/collector/bin/collector"

# addr2line
ADDR2LINE=`which addr2line`

# Path to the executable
EXECUTABLE="${REPLICATION_DIR}/experiments/mitgcm/MITgcm/verification/$NAME/build/mitgcmuv"

# Dynamic and static prefix
DYNAMIC_PREFIX="$PREFIX/$NAME/build/"
STATIC_PREFIX="/home/hschnoor/eclipse-workspace/PlayPython/resources/preprocessed/MITgcm-$NAME/"

# Hostname where the dynamic analysis was executed
HOST=lisboa
```

Of course the HOST variable must be changed to the name of the machine
the experiments are run.

The next file you have to create is a list of all experiments you want
to run. The file must be named `experiments`. A list of all experiments
which are used in the tutorial of MITgcm are listed in `tutorials` and
all other experiments are listed in `normal`. 

## Run Experiments

**Note:** For test purposes, it is helpful run the data collection with
one experiment only.

To run a single experiment you can type
```
cd ${SCRIPTS_DIR}
./run-dynamic-observation.sh" tutorial_barotropic_gyre
```
where `tutorial_barotropic_gyre` is the experiment to be executed.

**Note:** This will automatically create a new experiments file with 
`tutorial_barotropic_gyre` as only entry.

While the script tries to setup all experiments as intended, some will
not run or even compile. These need additional setup instructions which
can be found in the respective experiment folder.

You also may want to increase the runtime of certain experiments, to
ensure that all parts of the experiment are used. Such instructions
can also be found in the respecticve experiment directory and online
at `https://mitgcm.readthedocs.io/en/latest/examples/examples.html`.

## Static Analysis

-- added here -- TODO (hs)

## Architecture Reconstruction

Lets assume you have collected the dynamic and static data for a
MITgcm experiment, e.g., `tutorial_barotropic_gyre` and you are in
the `experiments/ecsa-mitgcm` directory. Now you can run the analysis
for the experiment with

`./run-architecture-analysis.sh tutorial_barotropic_gyre`

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

You can use `./run-all-analysis.sh experiments` to run all experiment
architecture analyses automatically.

You can use the `dotPic-fileConverter.sh` from the Kieker archive to
convert all dot files. This tool requires `dot` installed on your
machine.
