### ---------------------swm-instrumentation----------------------------
##### 1. Install Kieker-language-c pack
- load git rep with `git clone https://github.com/kieker-monitoring/kieker-lang-pack-c.git`
- run following commands
	- `libtoolize`
	- `aclocal`
	- `automake --add-missing`
	- `autoconfig`
- go in the `libkieker`folder and run following commands
	- `export KIEKER_HOSTNAME=127.0.0.1`
	- `export KIEKER_PORT=5678`
	- `./configure && make && make install`

##### 2. Load Kieker Collector
- load the latest Kieker Binaries, i.e. here https://kieker-monitoring.net/download/
- goto `tools` folder ad unzip the `collector`
- make a file with the name `collector.conf`and paste that in it:
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
- edit the custom storage path
- run the collector with `./collector -c collector.conf`
	
##### 3. bind the Shallow-Water-Model to Kieker
- edit the makefile of the swm model:
	- change line 2 to: `FCFLAGS = -g -O2 -ffree-form -ffree-line-length-none -fimplicit-none -finstrument-functions`
	- add to line 42: ` -lkieker`
- run `make` after editing
- then you can run the model as u behave

##### 4. Troubleshooting
- if it says connection refused [111] then the port is wrong or your firewall is not right configured

Fix:
- for fwd run: `sudo fwd allow 5678/tcp`
- you can lookup the change in fwd with `sudo fwd status`

### Analyse the result

First of all your Kieker-Logs are not filled with usual information due to Fortran parsing there are rom-access memoryaddresses saved in them.
To parse and convert them to operations called within the run of the model you have to use the rewrite_log_entries tool:

1. Clone the git with `git clone gitlab@git.se.informatik.uni-kiel.de:oceandsl/oceandsl-tools.git`
2. run `sudo apt install binutils -y`
3. open the project in eclipse and run the ^^tool with following parameters:
	- `-i [kieker logs folder] -o [output of kieker logs] -a /usr/bin/addr2line -m [path to model executable]`
	- you can add this run-configuration to eclipse manually by changing the run parameters:
		- click on `run` then on `run configirations...`
		- search for the correct java executable and click on it
		- press Arguments and paste the arguments from above in the text field under `Program Arguments`
4. after running your log files are ready to analyse
5. i.e. run: ```
dar-1.3.0-SNAPSHOT/bin/dar -i [kieker-folder]/ -o [output folder] -s ELF -E demo -l label

mvis-1.3.0-SNAPSHOT/bin/mvis -i [input folder] -o [output folder] -g dot-op -m add-nodes -s all 

dot -Tpdf output/models-operation.dot > example.pdf
```
