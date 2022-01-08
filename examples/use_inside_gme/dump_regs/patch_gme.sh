#!/usr/bin/env bash

new_gme=patched_game.gme
echo "[INFO] new_gme=$new_gme"

# parse CSV file, extract binary for every row entry
idx=1
last_offset=0
last_size=0
while IFS=, read -r offset size
do
    # copy start before first binary
    if((idx == 1)); then
        echo [INFO] dd status=none iflag=skip_bytes,count_bytes count="$((offset))" if="game.gme" of="$new_gme"
        dd status=none iflag=skip_bytes,count_bytes count="$((offset))" if="game.gme" of="$new_gme"
    else
        echo [INFO] dd status=none iflag=skip_bytes,count_bytes skip=$((last_offset + last_size)) if="game.gme" count=$((offset - (last_offset + last_size))) of="$new_gme" conv=notrunc oflag=append 
        dd status=none iflag=skip_bytes,count_bytes skip=$((last_offset + last_size)) if="game.gme" count=$((offset - (last_offset + last_size))) of="$new_gme" conv=notrunc oflag=append 
    fi

    # extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
    echo [INFO] dd status=none iflag=skip_bytes,count_bytes if="game$((idx)).bin" count=$((size)) of="$new_gme" conv=notrunc oflag=append 
    dd status=none iflag=skip_bytes,count_bytes if="game$((idx)).bin" count=$((size)) of="$new_gme" conv=notrunc oflag=append 
    echo [INFO] dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$(( $((size)) - `wc -c < game$((idx)).bin` )) of="$new_gme" conv=notrunc oflag=append 
    dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$(( $((size)) - `wc -c < game$((idx)).bin` )) of="$new_gme" conv=notrunc oflag=append 

    idx=$((idx + 1))
    last_offset=$offset
    last_size=$size
done < binaries.csv

# copy rest of the original file
echo [INFO] dd status=none iflag=skip_bytes,count_bytes skip="$((last_offset + last_size))" if="game.gme" conv=notrunc oflag=append of="$new_gme"
dd status=none iflag=skip_bytes,count_bytes skip="$((last_offset + last_size))" if="game.gme" conv=notrunc oflag=append of="$new_gme"


md5sum "$new_gme"

# The patched_gme.gme should be renamed to the original file name;
# afterwards, it should be loaded on the pen (at your own risk!)

