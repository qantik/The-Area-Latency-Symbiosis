#!/bin/bash
if diff  Testoutput.txt tb_output.txt; then
	echo "Simulation is successful"
else
	echo "Simulation has failed"
fi
