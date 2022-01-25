#!/usr/bin/env bash

game_file=$1
binary_out_file=binaries.csv
TTTOOL_PATH=/Users/maehw/Apps/tttool-1.10/
echo "[DEBUG] game_file='${game_file}'"
echo "[DEBUG] binary_out_file='${binary_out_file}'"
echo "[DEBUG] TTTOOL_PATH='${TTTOOL_PATH}'"
echo ""

if [ "$game_file" == "" ]; then
  echo "[ERROR] A game file name needs to be provided as command line argument:"
  echo "Usage: ./analyze_gme.sh game.gme"
  echo ""
  exit
fi

# Get info about the game via `tttool`
echo "------------------------------------------------------------"
echo "[INFO] Calling tttool to dump info about the game file:"
echo "[INFO] Calling '${TTTOOL_PATH}tttool info ${game_file}'..."
echo ""
${TTTOOL_PATH}tttool info ${game_file}
[ $? -eq 0 ] || { echo "[ERROR] tttool failed"; exit; }

# Especially interesting are the locations of the binaries;
# use offset and size for the next scripts (until the whole process has been automated)
echo "------------------------------------------------------------"
echo "[INFO] Calling tttool to show location of binaries (human-readable):"
echo "[INFO] Calling '${TTTOOL_PATH}tttool explain ${game_file} | grep binary'..."
echo ""
${TTTOOL_PATH}tttool explain ${game_file} | grep binary
[ $? -eq 0 ] || { echo "[ERROR] tttool failed"; exit; }

# Extract offsets and sizes of game binaries
echo "-------------------------------------------------------------------------------------------------------------------------"
echo "[INFO] Calling tttool to extract location of binaries (machine-readable), will be stored in ${binary_out_file}:"
echo "[INFO] Calling ''${TTTOOL_PATH}tttool explain ${game_file} | grep -i -e 'single.*binary.*main' | awk '{print $2","substr($4,1,length($4)-1)}' | tee ${binary_out_file}''"
echo ""
${TTTOOL_PATH}tttool explain ${game_file} | grep -i -e 'single.*binary.*main' | awk '{print $2","substr($4,1,length($4)-1)}' | tee ${binary_out_file}
[ $? -eq 0 ] || { echo "[ERROR] tttool failed"; exit; }
