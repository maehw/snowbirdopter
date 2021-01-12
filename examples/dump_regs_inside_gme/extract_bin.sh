#!/usr/bin/env bash

# parse CSV file, extract binary for every row entry
idx=1
while IFS=, read -r offset size
do
    # Extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
    dd status=none iflag=skip_bytes,count_bytes skip="$((offset))" if="game.gme" count="$((size))" of="game$((idx)).bin"

    # Disassemble the binary and make assembly code available in separate file 'game.s'
    # -m machine|--architecture=machine: arm
    # -D|--disassemble-all
    # -b bfdname|--target=bfdname: binary
    # may consider using --no-show-raw-insn!
    arm-none-eabi-objdump -m arm -D -b binary "game$((idx)).bin" > "game$((idx)).s"

    idx=$((idx + 1))
done < binaries.csv

exit



