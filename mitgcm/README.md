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

## Preparations

Create a workspace for the analyis, e.g., `experiments`, and switch to
this directory.
```
mkdir experients
cd experiments
```

Clone the *ecsa-mitgcm* git repository containing the setup scripts.
```
git clone https://git.se.informatik.uni-kiel.de/oceandsl/ecsa-mitgcm.git
```

Clone the *oceandsl-java-tools* or retrieve them from the replication
package.
```
git clone https://git.se.informatik.uni-kiel.de/oceandsl/oceandsl-tools.git
```

Clone the *mitgcm* repository.
```
git clone https://github.com/MITgcm/MITgcm.git
```

Clone the *kieker-lang-pack-c* repository.
```
git clone https://github.com/kieker-monitoring/kieker-lang-pack-c.git
```

## Java Tools

Building the Java tools should be straight forward. Enter:
```
cd oceandsl-tools
./gradlew clean build
./assemble-tools.sh
cd ..
```

Install both tools as follows:
```
tar -xpf oceandsl-tools/build/oceandsl-tools.tgz
```

This creates a directory in your experiments folder containing
the respective tools in a bin folder.

## Install Kieker

Kieker is only needed in case you want to reproduce the dynamic analysis
i.e., the observation of the model behavior at runtime.

```
cd kieker-lang-pack-c
cd source
```

Follow the installation instructions there. In short perform the following

```
libtoolize
aclocal
automake --add-missing
autoconf
```

Then compile and install the monitoring probes.
```
./configure ; make
```

You may also call `make install`. However, this may require admin
privileges.

Switch back to the experiments directory
```
cd ..
```

From the Kieker binary distribution archive, extract the file
`kieker-1.14/tools/collector-1.14.zip` from the archive.
Then unpack the tool as follows:
```
unzip collector.zip
```

This installs the collector tool alongside the two tools from OceanDSL.

Please note: You can also use the more recent binary distribution
kieker-1.15-SNAPSHOT.

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

If all works well, go back to the `experiments` directory, e.g.,
```
cd ../..
```

## Setting up the Experiments

Lets assume you are in the main `experiments` folder.
Switch to `ecsa-mitgcm`.
```
cd ecsa-mitgcm
```

Here you need to create a `config` file. There are examples of the 
file available. Lets assume your user account is called `trillian` and
the home directory is `/home/trillian` containing the `experiments`
folder. Then the configuration file should look like this:

```
# PREFIX for the mitgcm model variants
PREFIX="/home/trillian/experiments/MITgcm/verification"

# Library path including Kieker libraries
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/trillian/experiments/kieker-lang-pack-c/libkieker/.libs"

# Compile configurtion for kieker
export CONFIGURATION="${BASE_DIR}/linux_amd64_gfortran_kieker"

# Location for the observed monitoring data for each model variant
export DATA_PATH="$BASE_DIR/dynamic-data"

# Location for dynamic and static data
export DYNAMIC_DATA_PATH="${DATA_PATH}"
export STATIC_DATA_PATH="$BASE_DIR/static-data"

# prepocessor
PREPROCESS="${BASE_DIR}/../pp-static-log/bin/pp-static-log"

# arcitecture analysis tool
ANALYSIS="${BASE_DIR}/../create-architecture-model/bin/create-architecture-model"

# collector tool 
COLLECTOR="${BASE_DIR}/../collector-1.14/bin/collector"

# addr2line
ADDR2LINE=`which addr2line`

# Path to the executable
EXECUTABLE="$BASE_DIR/../MITgcm/verification/$NAME/build/mitgcmuv"

# Dynamic and static prefix
DYNAMIC_PREFIX="$PREFIX/$NAME/build/"
STATIC_PREFIX="/home/trillian/experiments/PlayPython/resources/preprocessed/MITgcm-$NAME/"

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
./run-dynamic-observation.sh tutorial_barotropic_gyre
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

-- added here --

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
