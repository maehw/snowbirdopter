#!/usr/bin/env bash

set -e

dd status=none iflag=skip_bytes,count_bytes count="$((0x0256130A))" if="game.gme"                                          of="patched_game.gme"
dd status=none iflag=skip_bytes,count_bytes if=out.bin count=2828                                conv=notrunc oflag=append of="patched_game.gme"
dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$((2828 - $(wc -c < out.bin)))    conv=notrunc oflag=append of="patched_game.gme"
dd status=none iflag=skip_bytes,count_bytes skip="$((0x0256130A + 2828))" if="game.gme"          conv=notrunc oflag=append of="patched_game.gme"
