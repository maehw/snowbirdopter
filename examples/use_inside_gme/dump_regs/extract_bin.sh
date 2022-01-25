#!/usr/bin/env bash

game_file=$1
binary_out_file=binaries.csv
echo "[DEBUG] game_file='${game_file}'"
echo "[DEBUG] binary_out_file='${binary_out_file}'"
echo ""

if [ "$game_file" == "" ]; then
  echo "[ERROR] A game file name needs to be provided as command line argument:"
  echo "Usage: ./extract_bin.sh game.gme"
  echo ""
  exit
fi

# check if running on Mac OS because we want to use non-default 'dd' there
if [[ "$OSTYPE" == "darwin"* ]]; then
    # use default installation path of GNU utilities 'dd' installed via
    # 'brew install coreutils' on Mac OS
    DD_DIR=/usr/local/opt/coreutils/libexec/gnubin/
else
    DD_DIR=
fi

# parse CSV file, extract binary for every row entry
idx=1
while IFS=, read -r offset size
do
    # Extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
    echo [INFO] ${DD_DIR}dd iflag=skip_bytes,count_bytes skip="$((offset))" if="${game_file}" count="$((size))" of="game$((idx)).bin"
    ${DD_DIR}dd iflag=skip_bytes,count_bytes skip="$((offset))" if="${game_file}" count="$((size))" of="game$((idx)).bin"
    [ $? -eq 0 ] || { echo "[ERROR] dd failed"; exit; }

    # Disassemble the binary and make assembly code available in separate file 'game.s'
    # -m machine|--architecture=machine: arm
    # -D|--disassemble-all
    # -b bfdname|--target=bfdname: binary
    # may consider using --no-show-raw-insn!
    echo [INFO] arm-none-eabi-objdump -m arm -D -b binary "game$((idx)).bin" > "game$((idx)).s"
    arm-none-eabi-objdump -m arm -D -b binary "game$((idx)).bin" > "game$((idx)).s"
    [ $? -eq 0 ] || { echo "[ERROR] arm-none-eabi-objdump failed"; exit; }

    idx=$((idx + 1))
done < ${binary_out_file}
