#!/usr/bin/env bash

# Get info about the game via `tttool`
echo "tttool info game.gme"
echo "------------------------------------------------------------"
tttool info game.gme

# Especially interesting are the locations of the binaries;
# use offset and size for the next scripts (until the whole process has been automated)
echo ""
echo "tttool explain game.gme | grep binary"
echo "------------------------------------------------------------"
tttool explain game.gme | grep binary

# Extract offsets and sizes of game binaries
echo ""
echo "tttool explain game.gme | grep -i -e 'single.*binary.*main' | awk '{print $2","substr($4,1,length($4)-1)}' | tee binaries.csv"
echo "-------------------------------------------------------------------------------------------------------------------------"
tttool explain game.gme | grep -i -e 'single.*binary.*main' | awk '{print $2","substr($4,1,length($4)-1)}' | tee binaries.csv

