# Recovering multiple Revisions of an model architecture

All scripts can be used on different revisions of a model, as they only work
on the content of the model directory. In case your model is stored in a
git repository, you can checkout different revisions, releases, branches or
tags and then run the necessary recovery scripts for the respecitve model.

Later you may want to compare architectures with each other. This can
be done with oceandsl tools or their Kieker versions. For the paper, we
used the oceandsl tools. The Kieker tools are maintained by the Kieker
project and may deviate at some point in the future in features and
commandline parameters.

## Recovering multiple revisions of a model

1. Setup the generic `config` located in the directory of this readme.
2. Follow the instructions for the experiment setup of the model you
   want to analyze.
3. Before starting the scripts, go to the models source directory, checkout
   a revision and set the revision variable with the name of the git tag,
   branch or revision name.
   ```
   export REVISION=my-revision
   ```
4. Run the recovery and analysis scripts as you like. This will produce
   in the `${DATA_DIR}` for the respective model and revision all the
   necessary output.
5. Repeat this with as many revisions you like.

You can also automate. Here an example for mitgcm and the `tutorial_barotropic_gyre` 
model:
```
export SCRIPTS_DIR="${REPLICAITON_DIR}/esm-architecture-analysis-replication-package/models/mitgcm"
cd "${REPLICATION_DIR}"
for REVISION in checkpoint60 checkpoint61a checkpoint61t ; do
   cd "experiments/mitgcm/MITgcm
   git clean -f -d
   git checkout "${REVISION}"
   "${SCRIPTS_DIR}/run-static-code-processing.sh" tutorial_barotropic_gyre
   # Instead of call you can use dataflow or both as parameters
   "${SCRIPTS_DIR}/run-static-analysis.sh tutorial_barotropic_gyre call
done
```
 
## Comparing multiple models

Assuming you followed the above tutorial, you have in the
`${REPLICATION_DIR}/data/mitgcm` directory multiple subdirectories
named `checkpoint60`, `checkpoint61a`, and `checkpoint61t`.

They contain models with the same name, but different content. To compare them
and use coloring features of the Kieker Development Tools, we have to mark modules
in the models, merge them and tell the Kieker Development Tools how to color them.

The Kieker Development Tools, can be found here together with the necessary instructions
for installation.
`https://kieker-monitoring.readthedocs.io/en/latest/kieker-tools/IRL-Tool.html#kieker-tools-irl`

For the comparision, we have to do the following steps:
1. To have short path to the tools you may set this path or add the path to your PATH variable.
```
export TOOLS_DIR="${REPLICATION_DIR}/oceandsl-tools/bin"
```
2. Add labels to the models to mark every content element.
```
${TOOLS_DIR}/relabel -e demo-c60 -i "${REPLICATION_DIR}/data/mitgcm/checkpoint60" -o c60 -r static-call:static-call,c60
${TOOLS_DIR}/relabel -e demo-c61t -i "${REPLICATION_DIR}/data/mitgcm/checkpoint61t" -o c61t -r static-call:static-call,c61t
```
This adds revision information to all elements in the architecture.

3. Merge models
```
${TOOLS_DIR}/mop -e demo-c60-c61t -i c60 c61t -o c60-c61t merge
```

4. Add a coloring profile to the result model named `color-model.map` with the
following content:
```
component: c61t=#a0ffa0, #90f090
operation: c61t=#d0ffd0, #c0ffc0
component: c60=#a0a0ff, #9090f0
operation: c60=#d0d0ff, #c0c0ff
component: c61t, c60=#ffff00, #d0d000
operation: c61t, c60=#f0f000, #e0e000
```
This map will color modules and operation for the c61t (checkpoint61t) model in green, for
the c60 (checkpoint60) model in blue, and modules and operations that appear in both models in yellow.

Alternatively, you can generate graphics with the `mvis` tool
`https://kieker-monitoring.readthedocs.io/en/latest/kieker-tools/mvis.html#kieker-tools-mvis`
on commandline using different selection schemes. See the documentation for details or just test out
the different selectors.

