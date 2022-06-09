# Earth System Model - Architecture Recovery, Analysis and Restructuring Replication-Package

This package contains information to perform architecture recovery and analysis, and supports
remodularization proposals for Earth System Models (ESM). This README.md only provides an
overview on the setup.

Directory structure:
- oceandsl-tools.tgz collection of OceanDSL tools used in the recovery and analysis
- TODO python tools.
- mitgcm experiment scripts and configurations for mitgcm experiments
- uvic experiment scripts and configurations for uvic experiments


## Current Analyzed Models

- MITgcm
- UVic

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


