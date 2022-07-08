# Earth System Model - Architecture Recovery, Analysis and Restructuring Replication-Package

This package contains information to perform architecture recovery and analysis, and supports
remodularization proposals for Earth System Models (ESM). This README.md provides an overview
on the setup.

Directory structure:
- oceandsl-tools.tgz = collection of OceanDSL tools used in the recovery and analysis
- TODO python tools.
- models = containing scripts and configuration
  - mitgcm
  - uvic
  - swm

## Current Analyzed Models

- MITgcm
- UVic
- SWM

The corresponding subdirectories of the replication package contain detailed instructions for each
step to be done to setup the experiments and execute them.

## General Approach

We use dynamic and static approaches to recover the architecture and perform subsequent operations
on the architecture.

### Dynamic Analyis

- Instrument ESM with Kieker4C
- Collect instrumentation data
- Process data with dynamic architecture recovery tool (dar) to generate an architecture model

### Static Analysis

- Perform the configuration and preprocess stage of the compilation of an ESM
- Run esm call and dataflow extractor (based on fparser)
- Process data with the static architecture recovery tool (sar)

### Combine Models

- Use Model Merger (mop) to gain a combined model

### Architecture Inspection and Evaluation

- Generate visual represenations of the architecture with the Model Visualization Tool (mvis)
- Generate metrics based on the architecture with mvis
- Interactively inspect the architecture with Kieker Architecture Visualization

### Compute Restructuring

TODO (hs)

## Common Setup

All the analysis use the OceanDSL-Tools and TODO @hs. You can either extract the tools from
the archive in this replication package or clone and build the tools yourself.

### Installing Java

You need to install a Java runtime (at least Java 11 when you use the pre packaged tools or
Java 8 when you build the code yourself).

### OceanDSL-Tools

Installing OceanDSL-Tools from the *archive*:

```
tar -xvpf oceandsl-tools.tgz
```

Installing the OceanDSL-Tools from their *git repository*:

Clone the repository
```
git clone https://git.se.informatik.uni-kiel.de/oceandsl/oceandsl-tools.git
```

Change into the repository directory and build the tools.
```
cd oceandsl-tools
./gradlew build
./assemble-tools.sh
cd ..
tar -xvpf oceandsl-tools/build/oceandsl-tools.tgz
```

### Kieker Monitoring

Kieker is only needed in case you want to reproduce the dynamic analysis
i.e., the observation of the model behavior at runtime.

Clone the *kieker-lang-pack-c* repository.
```
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

In case you intend to install the Kieker library in a different location than
/usr/local you must specify a suitable path with the configure call, e.g.,
```
./configure --prefix=/home/mylocation/kieker
make
```
 
### Kieker Collector

You may use the collector bundled in the replication package. Therefore,
extract the archive in place.

```
tar -xvpf collector.tgz
```

Additional information on the collector and how to use it to collect
monitoring data, you may find on the Kieker documentation page.

https://kieker-monitoring.readthedocs.io/en/latest/kieker-tools/Collector---Kieker-Data-Bridge.html#kieker-tools-collector
