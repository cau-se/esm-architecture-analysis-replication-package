# SWM Instrumentation

The Shallow Water Model (SWM) was created among others by Martin Claus.
In this how to, we provide a detailed description on how to setup the
SWM for monitoring.

## Prerequisites

Follow the main README.md on how to setup the analysis tooling and build
the Kieker language pack for C and Fortran.

**Installed software**
- kieker-lang-pack-c
- Java 11 or above
- Kieker collector (part of the replication package)
- OceanDSL tools (part of the replication package)
- git installed
- GNU binutils, especially addr2line
- gcc anf gfortran
- netcdf, netcdff, udunits and their development packages
- make, autoconf, automake and other necessary build tools

We assume the following directory structure:
- replication
  - esm-architecture-analysis-replication-package
  - experiments
  - install

## Obtain the SWM

Lets assume that you are in the `replication` directory.

Create in the `experiments` directory a directory `swm` to hold all necessary
artifacts and change to that directory

`mkdir experiments/swm`
`cd experiments/swm`

Obtain the model from its gitlab repository

`git clone https://git.geomar.de/swm/swm.git`

## Build the SWM

Change to the repository directory.

`cd swm`

Your path will look like a bit like this `replication/experiments/swm/swm`

Here you can follow the instructions in the `README.md` of the model. However,
we provide a brief description here.

Execute the following commands:

`./configure`

If it fails, you might have to install additional packages. Often people have
installed the necessary libraries, but not the necessary development files.

This will produce a `Makefile`. The `Makefile` assumes that there is a
`build` directory, but as git does not support empty directories, it is
necessary to create it now.

`mkdir build`

Now you can test compile the model with:

`make`

It the compilation is successful, it is time to proceed to the next step and
add the instrumentation.

## Instrumenting the SWM

In the previous step, we produced a `Makefile` by running `configure`.
Now we have to adapt the `Makefile`. 
Open the `Makefile` in an editor and perform the following operations.
 - change line 2 to: `FCFLAGS = -g -O0 -ffree-form -ffree-line-length-none -fimplicit-none -finstrument-functions`
   - The -g option adds debugging symbols which we need later on
   - The -O0 ensures that no function is removed from the executable, yes this
     has a negative impact on the execution time, but otherwise not all
     functions can be instrumented.
 - add to line 42: ` -lkieker -L$KIEKER_PATH`
   KIEKER_PATH must point to the directory you installed the lib files of the
   kieker-lang-pack-c. The default location is in `/usr/local/lib`, but in case
   you followed the instructions from the main README.md, they are located in
   `replication/install/kieker/lib`. Please specify an absolute path here, as
   often relative path can make things messy.
 - run `make`

## Collect monitoring events

To ensure we can collect all monitoring events from the SWM, we need to setup
and start the event collector.

Go to the swm experiment directory `replication/experiments/swm`

Create a `collector.conf` file as follows:
```
# Kieker settings

## The name of the Kieker instance.
kieker.monitoring.name=KIEKER

## Auto detect hostname for the writer
kieker.monitoring.hostname=

## Output metadata record
kieker.monitoring.metadata=true

# TCP servcer for multiple connections

kieker.tools.source=kieker.tools.source.MultipleConnectionTcpSourceCompositeStage
kieker.tools.source.MultipleConnectionTcpSourceCompositeStage.port=5678
kieker.tools.source.MultipleConnectionTcpSourceCompositeStage.capacity=8192

# Define output

## Data sink stage (FileWriter)
kieker.monitoring.writer=kieker.monitoring.writer.filesystem.FileWriter

## FileWriter settings

## output path
kieker.monitoring.writer.filesystem.FileWriter.customStoragePath=
kieker.monitoring.writer.filesystem.FileWriter.charsetName=UTF-8

## Number of entries per file
kieker.monitoring.writer.filesystem.FileWriter.maxEntriesInFile=25000

## Limit of the log file size; -1 no limit
kieker.monitoring.writer.filesystem.FileWriter.maxLogSize=-1

## Limit number of log files; -1 no limit
kieker.monitoring.writer.filesystem.FileWriter.maxLogFiles=-1

## Map files are written as text files
kieker.monitoring.writer.filesystem.FileWriter.mapFileHandler=kieker.monitoring.writer.filesystem.TextMapFileHandler

## Flush map file after each record
kieker.monitoring.writer.filesystem.TextMapFileHandler.flush=true

## Do not compress the map file
kieker.monitoring.writer.filesystem.TextMapFileHandler.compression=kieker.monitoring.writer.compression.NoneCompressionFilter

## Log file pool handler
kieker.monitoring.writer.filesystem.FileWriter.logFilePoolHandler=kieker.monitoring.writer.filesystem.RotatingLogFilePoolHandler

## Text log for record data
kieker.monitoring.writer.filesystem.FileWriter.logStreamHandler=kieker.monitoring.writer.filesystem.TextLogStreamHandler

## Do not compress the log file
kieker.monitoring.writer.filesystem.TextLogStreamHandler.compression=kieker.monitoring.writer.compression.NoneCompressionFilter

## Flush log data after every record
kieker.monitoring.writer.filesystem.FileWriter.flush=true

## buffer size. The log buffer size must be big enough to hold the biggest record
kieker.monitoring.writer.filesystem.FileWriter.bufferSize=81920
```

Set the `customStoragePath` to the path inside your experiment directory, e.g.,
`replication/experiments/swm`
Please make this an absolute path, e.g., `/home/eve/temp/replication/experiments/swm`

Run the collector with

`../../install/collector/bin/collector -c collector.conf`

This will output something like:
```
17:34:35.724 [main] INFO  k.m.core.controller.TCPController - Could not parse port for the TCPController, deactivating this option. Received string was: 
17:34:35.738 [main] INFO  k.m.core.controller.StateController - Enabling monitoring
17:34:35.743 [main] INFO  k.m.c.c.MonitoringController - Current State of kieker.monitoring (2.0.0-SNAPSHOT) Status: 'enabled'
	Name: 'KIEKER'; Hostname: 'glasgow'; experimentID: '1'
JMXController: JMX disabled
TimeSource: 'kieker.monitoring.timer.SystemNanoTimer'
	Time in nanoseconds (with nanoseconds precision) since Thu Jan 01 01:00:00 CET 1970'
ProbeController: disabled
WriterController:
	Queue type: class kieker.monitoring.queue.BlockingQueueDecorator
	Queue capacity: 10000
	Insert behavior (a.k.a. QueueFullBehavior): class kieker.monitoring.queue.behavior.BlockOnFailedInsertBehavior
		numBlocked: 0
Writer: 'kieker.monitoring.writer.filesystem.FileWriter'
	Configuration:
		kieker.monitoring.writer.filesystem.FileWriter.logFilePoolHandler='kieker.monitoring.writer.filesystem.RotatingLogFilePoolHandler'
		kieker.monitoring.writer.filesystem.FileWriter.charsetName='UTF-8'
		kieker.monitoring.writer.filesystem.FileWriter.logStreamHandler='kieker.monitoring.writer.filesystem.TextLogStreamHandler'
		kieker.monitoring.writer.filesystem.FileWriter.bufferSize='81920'
		kieker.monitoring.writer.filesystem.FileWriter.maxEntriesInFile='25000'
		kieker.monitoring.writer.filesystem.FileWriter.maxLogFiles='-1'
		kieker.monitoring.writer.filesystem.FileWriter.maxLogSize='-1'
		kieker.monitoring.writer.filesystem.FileWriter.mapFileHandler='kieker.monitoring.writer.filesystem.TextMapFileHandler'
		kieker.monitoring.writer.filesystem.FileWriter.flush='true'
		kieker.monitoring.writer.filesystem.FileWriter.customStoragePath='/home/eve/temp/replication/experiments/swm'
		kieker.monitoring.writer.filesystem.FileWriter.actualStoragePath='/home/eve/temp/replication/experiments/swm/kieker-20221125-163435-110581488230205-UTC--KIEKER'

	Automatic assignment of logging timestamps: 'true'
Sampling Controller: Periodic Sensor available: Poolsize: '0'; Scheduled Tasks: '0'
17:34:35.748 [main] INFO  teetime.framework.Execution - Using scheduler: teetime.framework.scheduling.pushpullmodel.PushPullScheduling@1b52699c
```

These are all settings used by Kieker and the collector.

## Run the SWM

Let us open a second terminal window.
and switch to `replication/experiments/swm`

Go to the model directory

`cd swm`

Edit the `model.namelist` for your experiment. In case you have no special 
wishes, you can copy the `model.namelist` from the replication package.
First store the original `model.namelist` as reference.

`mv model.namelist model.namelist.original`

The copy our example file to the right location.

`cp ../../../esm-architecture-analysis-replication-package/models/swm/model.namelist .`

When you use our `model.namelist`, results of the model are placed in a
directory called `out`. Create it with:

`mkdir out`

Now everything is set up correctly and we can run the model with:

`bin/model`

If everything works, on the other terminal the collector will print out
information on the number of received events.

```
17:34:40.510 [Thread-3] INFO  k.analysis.generic.sink.DataSink - Saved 100000 records.
17:34:42.160 [Thread-3] INFO  k.analysis.generic.sink.DataSink - Saved 200000 records.
17:34:44.097 [Thread-3] INFO  k.analysis.generic.sink.DataSink - Saved 300000 records.
```

Our setup produces usually 2500000 records.

When the model is finished, it will have outputted something like this:
```
Kieker Configuration
	collector hostname = localhost
	collector port = 5678
2022-11-25 17:34:37.781 INFO initIO done
2022-11-25 17:34:37.782 INFO initDomain done
2022-11-25 17:34:37.787 INFO initVars done
2022-11-25 17:34:37.790 INFO initCalcLib done
2022-11-25 17:34:37.790 INFO time_integration_init done
2022-11-25 17:34:37.792 INFO swm_vars_init done
2022-11-25 17:34:37.794 INFO swm_timestep_init done
2022-11-25 17:34:37.796 INFO swm_damping_init done
2022-11-25 17:34:37.798 INFO swm_forcing_init done
2022-11-25 17:34:37.798 INFO SWM_init done
2022-11-25 17:34:37.807 INFO initDiag done
2022-11-25 17:34:37.809 INFO first call of Diag done
2022-11-25 17:34:37.809 INFO starting integration
itt =      34680 (100.0% of      34680) doneSTOP 0
```

Now you can terminate the collector with CTRL-C on its terminal. This is
necessary, as the collector allows monitored applications to reconnect or
connect via multiple TCP streams. Thus, it cannot detect when the application
is finished.
CTRL-C will terminate the collector gracefully.

## Hints, Fixes and Known Issues

In case the SWM says connection refused [111], the port is wrong or your
firewall is not right configured

Fix:
- for fwd run: `sudo fwd allow 5678/tcp`
- you can lookup the change in fwd with `sudo fwd status`

In case you setup the collector to a different port or run it on a different
host, you can tell the SWM to use another port and host with

`export KIEKER_PORT=5678`
`export KIEKER_HOSTNAME=127.0.0.1`

The here depicted numbers are the default values.

## Analyze the result

Your monitoring results should be located in `replication/experiments/swm/` in a
directory named, similar to `kieker-20221125-163435-110581488230205-UTC--KIEKER`
As you can see, the directory name contains the date and time of your analysis.

For the analysis we use the `dar` tool from the `oceandsl-tools` package.
Lets switch to `replication/experiments/swm`.

Lets create a target director for the reconstructed architecture.

`mkdir swm-dynamic`

Then we can run the architecture reconstruction with:

```
../../oceandsl-tools/bin/dar -i $KIEKER_LOG_FOLDER -o swm-dynamic \
    -a /usr/bin/addr2line -e swm/bin/model -m module-mode file-mode \
    -E replication-experiment -s elf -l dynamic
```

 - `KIEKER_LOG_FOLDER` the the folder containing the kieker log, e.g.,
   `kieker-20221125-163435-110581488230205-UTC--KIEKER` from the example above.
 - `swm-dynamic` is the directory where the recovered architecture is stored in.
 - `/usr/bin/addr2line` is the tool to resolve the function names from the
   executable
 - `swm/bin/model` is the relative path the the compiled model
 - `-m module-mode file-mode` defines the recovery strategy. The first aims to
   extract the module and operation name from the fully qualified function name
   in the debug symbols, which follow the format `_module_name_MOD_function_name`
   The second option retrieves the module name from the file path of the
   function and the operation name from the function name of the debug symbols.
 - `-E replication-experiment` is the name of the experiment
 - `-s elf` defines the function name extractor to be used
 - `-l dynamic` defines the label which will be attached to every architecture
   element. This is helpful when mixing architectures.

## Visualize results

We have multiple tools available to perform further analysis of the architecture
model and generate visualizations.

For a quick test run:
```
mkdir swm-dynamic-results
../../.oceandsl-tools/bin/mvis -i swm-dynamic -o swm-dynamic-results \
    -g dot-op -m add-nodes -s all 
dot -Tpdf swm-dynamic-results/models-operation.dot > swm-dynamic-results/models-operation.pdf
```

Alternatively, you can use our Eclipse plugin visualization which is part of
the Kieker Development Tools. The Eclipse update site can be found here:

https://maui.se.informatik.uni-kiel.de/repo/kdt/snapshot/




