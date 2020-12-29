#!/usr/bin/env bash

# Extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
dd status=none iflag=skip_bytes,count_bytes skip="$((0x0AF5B273))" if="game.gme" count=22244 of="game.bin"

# Disassemble the binary and make assembly code available in separate file 'game.s'
# -m machine|--architecture=machine: arm
# -D|--disassemble-all
# -b bfdname|--target=bfdname: binary
# may consider using --no-show-raw-insn!
arm-none-eabi-objdump -m arm -D -b binary game.bin > game.s

