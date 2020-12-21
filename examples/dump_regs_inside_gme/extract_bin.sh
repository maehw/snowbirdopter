#!/usr/bin/env bash

# Extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
dd status=none iflag=skip_bytes,count_bytes skip="$((0x0AF5B273))" if="game.gme" count=22244 of="game.bin"

# Disassemble the binary and make assembly code available in separate file 'game.s'
arm-none-eabi-objdump --architecture=arm -D -b binary game.bin > game.s

