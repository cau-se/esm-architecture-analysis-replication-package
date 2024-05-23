# General Configuration and Setup

There are some configuration parameters relevant for all models and versions.
These are configured in this directory.

To configure the general parameters create a copy of `config.template`

`cp config.template config`

and edit the file accordingly.

For simple replication of the experiments, you need only to copy the file
and enter the fully qualified path name of the replication directory in the
config file.

```
export REPLICATION_DIR= +++ SETUP HERE +++
```

In case you also want to recover the architecture of different revisions,
you have to use a different setup for the `${DATA_DIR}`. The setup
is already in the `config` file.

Comment out the following line
```
export DATA_PATH="${REPLICATION_DIR}/data"
```

Remove the comments from these lines
```
#export DATA_PATH="${REPLICATION_DIR}/data/$REVISION"
#
#if [ ! -d "${DATA_PATH}" ] ; then
#   mkdir -p "${DATA_PATH}"
#fi
```

**Note:** Before using this option make sure you follow the instructions in the REVISIONS-README.md



