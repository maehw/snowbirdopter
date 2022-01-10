#!/usr/bin/env bash

# check if running on Mac OS because 'dd' then has no parameter called 'status'
if [[ "$OSTYPE" == "darwin"* ]]; then
    DD_PARAMS=bs=1
else
    DD_PARAMS=status=none iflag=skip_bytes,count_bytes
fi

# parse CSV file, extract binary for every row entry
idx=1
while IFS=, read -r offset size
do
    # Extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
    echo [INFO] dd ${DD_PARAMS} skip="$((offset))" if="game.gme" count="$((size))" of="game$((idx)).bin"
    dd ${DD_PARAMS} skip="$((offset))" if="game.gme" count="$((size))" of="game$((idx)).bin"

    # Disassemble the binary and make assembly code available in separate file 'game.s'
    # -m machine|--architecture=machine: arm
    # -D|--disassemble-all
    # -b bfdname|--target=bfdname: binary
    # may consider using --no-show-raw-insn!
    arm-none-eabi-objdump -m arm -D -b binary "game$((idx)).bin" > "game$((idx)).s"

    idx=$((idx + 1))
done < binaries.csv

exit
