# Earth System Model - Architecture Recovery, Analysis and Restructuring Replication-Package

This package contains information to perform architecture recovery and analysis,
and supports remodularization proposals for Earth System Models (ESM). This
README.md provides an overview on the setup and all shared tasks.

Specific information on each model can be found in the respective models
sub directories.

Directory structure:
- oceandsl-tools.tgz = collection of OceanDSL tools used in the recovery and
  analysis
- TODO python tools.
- models = containing scripts and configuration
  - mitgcm
  - uvic
  - swm

## Current Analyzed Models

- MITgcm
- UVic
- SWM (not yet available)

The corresponding subdirectories of the replication package contain detailed
instructions for each step to be done to setup the experiments and execute them.

## General Approach

We use dynamic and static approaches to recover the architecture and perform
subsequent operations on the architecture.

### Dynamic Analyis

- Instrument ESM with Kieker4C
- Collect instrumentation data
- Process data with dynamic architecture recovery tool (dar) to generate an
  architecture model

### Static Analysis

- Perform the configuration and preprocess stage of the compilation of an ESM
- Run esm call and dataflow extractor (based on fparser)
  - this is currently located in a git submodule in the directory python-coupling-analysis, can be cloned stand-alone with
    git clone https://python-analysis:glpat-Zk_T952XjXsxCLiRst1t@cau-git.rz.uni-kiel.de/ifi-ag-se/oceandsl/esm-coupling-analysis.git
- Process data with the static architecture recovery tool (sar)

### Combine Models

- Use Model Merger (mop) to gain a combined model

### Architecture Inspection and Evaluation

- Generate visual represenations of the architecture with the Model Visualization
  Tool (mvis)
- Generate metrics based on the architecture with mvis
- Interactively inspect the architecture with Kieker Architecture Visualization

### Compute Restructuring

- similarly a git submodule, clonable with
git clone https://java-restructuring:glpat-9EeDaDEM3RL25_81Xx-W@cau-git.rz.uni-kiel.de/ifi-ag-se/oceandsl/genetic-restructuring.git java-restructuring
- TODO: This submodule also contains the dynamic and static analysis results of UVic and MITgmc, which are also in the "models" directory of the replication package. It would be better to let the replication package offer a "complete workflow", where each step can either use the results of the previously performed step, or data supplied by us.

## Common Setup

All the analysis use the OceanDSL-Tools and TODO @hs. You can either extract the tools from
the archive in this replication package or clone and build the tools yourself.

### Experiment Directory

To avoid mixing replication package sources, data from other sources and
data from the replication you are executing, we suggest to use separate
experiment and install directories.

The envisioned setup is:
- replication
  - esm-architecture-analyisis-replication-package
  - install
    - kieker-lang-pack-c (git repo)
    - oceandsl-tools (git repo)
  - experiments
  - oceandsl-tools (created when following the instructions)
  - data
  
We will refer to the `replication` directory as `${REPLICATION_DIR}` in the
documentation.
In case you want to follow this recommendation, you have to create the
directories as follows.

```
mkdir replication
cd replication
mkdir install experiments data
```

Then move the `esm-architecture-analyisis-replication-package` (replication package)
directory into the `${REPLICATION_DIR}`.

### Installing Java

You need to install a Java runtime (at least Java 11). Follow the instructions
for your respective operating system. Most Linux distributions provide suitable
Java runtimes and SDKs.

### OceanDSL-Tools

Installing OceanDSL-Tools from the *archive* in the **replication package**:

```
tar -xvpf oceandsl-tools.tgz
mv oceandsl-tools ${REPLICATION_DIR}
```

Installing the OceanDSL-Tools from their *git repository*:

Clone the repository
```
cd ${REPLICATION_DIR}/install
git clone https://git.se.informatik.uni-kiel.de/oceandsl/oceandsl-tools.git
```

Change into the repository directory and build the tools.
```
cd oceandsl-tools
./gradlew build
./assemble-tools.sh
cd ${REPLICATION_DIR}
tar -xzpf ${REPLICATION_DIR}/install/oceandsl-tools/build/oceandsl-tools.tgz
```

### Kieker Monitoring

Kieker is only needed in case you want to reproduce the dynamic analysis
i.e., the observation of the model behavior at runtime.

Clone the *kieker-lang-pack-c* repository.
```
cd ${REPLICATION_DIR}/install
git clone https://github.com/kieker-monitoring/kieker-lang-pack-c.git
```

```
cd kieker-lang-pack-c/source
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

In case you intend to install the Kieker library in a different location then
`/usr/local` you must specify a suitable path with the configure call, e.g.,
```
./configure --prefix=${REPLICATION_DIR}/kieker
make
make install
```

### Kieker Collector

You may use the collector bundled in the replication package. Therefore,
extract the archive in place.

```
cd "${REPLICATION_DIR}"
unzip esm-architecture-analysis-replication-package/collector.zip
```
Depending on the version this will produce a directory named `collector-2.0.0-SNAPSHOT`.
Please rename this to `collector`.

Additional information on the collector and how to use it to collect
monitoring data, can be found in the Kieker documentation page.

`https://kieker-monitoring.readthedocs.io/en/latest/kieker-tools/Collector---Kieker-Data-Bridge.html#kieker-tools-collector`

In case the *collector* does not work, e.g., for incompatibilities, you can
download Kieker tools from 
`https://github.com/kieker-monitoring/kieker/releases/` in the tools or binary package.

### Install additional tooling

Install binutils which include `addr2line`. In debian based Linux distributions, this
is done with

`sudo apt install binutils -y`

In case you use a non-Debian distribution, install the corresponding package of your
distribution.

### Install fxtran

You may find `fxtran` in our fork `https://github.com/OceanDSL/fxtran` repository or
a more recent version in the original project.

To install `fxtran` which is required for the static architecture recovery, go to
the `${REPLICATION_DIR}/install` directory and clone the repository

```
cd ${REPLICATION_DIR}/install
git clone https://github.com/OceanDSL/fxtran
```

Compile the tool with

```
cd fxtran
make
cp bin/fxtran "${REPLICATION_DIR}"
```
