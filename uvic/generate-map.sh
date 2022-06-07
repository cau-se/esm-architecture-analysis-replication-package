#!/bin/bash

for I in * ; do
	if [ -d "$I" ] ; then
		cd $I
		for J in * ; do
			echo "$I , $J , <<unknown>>"
		done
		cd ..
	fi
done

# end
