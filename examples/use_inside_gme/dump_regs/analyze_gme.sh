#!/usr/bin/env bash

game_file=game.gme
binary_out_file=binaries.csv

# Note: Make sure the directory with the tttool executable is in the PATH environment variable.

# Get info about the game via `tttool`
echo "tttool info ${game_file}"
echo "------------------------------------------------------------"
tttool info ${game_file}

# Especially interesting are the locations of the binaries;
# use offset and size for the next scripts (until the whole process has been automated)
echo ""
echo "tttool explain ${game_file} | grep binary"
echo "------------------------------------------------------------"
tttool explain ${game_file} | grep binary

# Extract offsets and sizes of game binaries
echo ""
echo "tttool explain ${game_file} | grep -i -e 'single.*binary.*main' | awk '{print $2","substr($4,1,length($4)-1)}' | tee ${binary_out_file}"
echo "-------------------------------------------------------------------------------------------------------------------------"
tttool explain ${game_file} | grep -i -e 'single.*binary.*main' | awk '{print $2","substr($4,1,length($4)-1)}' | tee ${binary_out_file}
