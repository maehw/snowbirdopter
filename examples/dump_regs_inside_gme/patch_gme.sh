#!/usr/bin/env bash

set -e

# Use original game and replace the binary by own code
dd status=none iflag=skip_bytes,count_bytes count="$((0x0AF5B273))" if="game.gme"                                          of="patched_game.gme"
dd status=none iflag=skip_bytes,count_bytes if=out.bin count=22244                               conv=notrunc oflag=append of="patched_game.gme"
dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$((22244 - $(wc -c < out.bin)))   conv=notrunc oflag=append of="patched_game.gme"
dd status=none iflag=skip_bytes,count_bytes skip="$((0x0AF5B273 + 22244))" if="game.gme"         conv=notrunc oflag=append of="patched_game.gme"

md5sum patched_game.gme

# The patched_gme.gme should be renamed to the original file name;
# afterwards, it should be loaded on the pen (at your own risk!)
