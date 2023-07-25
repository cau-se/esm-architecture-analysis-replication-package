#!/bin/bash

for I in call dataflow both ; do
	for J in global_ocean.cs32x15 tutorial_barotropic_gyre tutorial_global_oce_biogeo ; do
		$1 $J $I
	done
done

# end
