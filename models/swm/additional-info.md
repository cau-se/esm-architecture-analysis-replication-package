### Shallow Water Model ESM Analysis

##### dynamic Analysis

The Model of the dynamic Analysis can be found in the 'dynamic_analysis' folder

- run the the model you want to analyse with kieker4c
  - howto: take a look at 'Kieker with swm.md'
- rewrite the log entries
  - i.e. with `rewrite-log-entries -i {input Kieker_logs} -o {output_folder} -a /usr/bin/addr2line -m {path to the model runned with Kieker}`
  - should the rewriter show you something like this: ```[Thread for DirectoryScannerStage-0] ERROR org.oceandsl.analysis.generic.stages.RewriteBeforeAndAfterEventsStage:RewriteBeforeAndAfterEventsStage-0 - Cannot process result 'initmodel.3 at ~/swm/./src/model.f90:71' for address 0x48bf0``` , then change the pattern to: `^([\\w.]+) at ([\\w\\?/\\.\\-]+):([\\d\\?]*)( .*)?$` in `org.oceandsl.analysis.generic.stages.RewriteBeforeAndAfterEventsStage.java`
- use the dar tool to make a model out of the kieker logs
  - i.e. with: ```dar -i {rewrote_kieker_entries_folder} -o {output_directory} -s ELF -E demo -l label -c```

##### static Analysis

The Model of the static Analysis can be found in the 'static_analysis' folder

- let a esm_coupling_analysis run over your models source files
  - the scripts for that can be found here: https://cau-git.rz.uni-kiel.de/ifi-ag-se/oceandsl/esm-coupling-analysis
  - preprocess the files: `sh preprocess.sh "/swm/src/" "{output_folder}" "-I/swm/include/ -I/swm/src/ -I/usr/local"`
  - run `methodcalls.py`: ```python3 methodcalls.py "{preprocessed_source_files}" "output/couplingcsv" "output/functionnamecsv" "output/log"```
- run the sar tool run over the generated files to create a model
  - i.e. with: ```sar -i {path_to_couplingcsv} -c -E swm -f {path_to_functionnamecsv} -H node1 -m missing-functions.txt -o {output_folder} -l static -ns ; -ds ; -cs ;```

##### merge the Analysis

- merge the models with the tool mop
  - i.e. with: `mop -i {path_to_model_1} {path_to_model_2} -o {output_folder} -e swm-merged`