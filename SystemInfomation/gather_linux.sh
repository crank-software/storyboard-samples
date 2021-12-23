#!/bin/sh

# This is a diagnostic utility for use on Linux platforms to gather 
# diagnostic information about the system and Storyboard's environment

if [ "$1x" == "x" ] 
then
	echo "Usage $0 <Storyboard Engine Directory>"
	exit
fi

$SB_ROOT=$1

# Print out the platform information
uname -a

# Print out the Storyboard information
export SB_PLUGINS=${SB_ROOT}/plugins
export LD_LIBRARY_PATH=${SB_ROOT}/lib
${SB_ROOT}/sbengine -i

# Grab a base process list
ps -elf 


