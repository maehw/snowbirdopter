#!/usr/bin/env bash

# check if running on Mac OS because we want to use non-default 'dd' there
if [[ "$OSTYPE" == "darwin"* ]]; then
    # use default installation path of GNU utilities 'dd' installed via
    # 'brew install coreutils' on Mac OS
    DD_DIR=/usr/local/opt/coreutils/libexec/gnubin/
else
    DD_DIR=
fi

new_gme=patched_game.gme
echo "[INFO] new_gme='$new_gme'"

# remove file first
rm $new_gme
# parse CSV file, extract binary for every row entry
idx=1
last_offset=0
last_size=0
while IFS=, read -r offset size
do
    # copy start before first binary
    if((idx == 1)); then
        echo [INFO] Copying start of original binary...
        echo [INFO] ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes count="$((offset))" if="game.gme" of="$new_gme"
        ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes count="$((offset))" if="game.gme" of="$new_gme"
        [ $? -eq 0 ] || { echo "[ERROR] dd failed"; exit; }
    else
        echo [INFO] Copying middle part of original binary...
        echo [INFO] ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes skip=$((last_offset + last_size)) if="game.gme" count=$((offset - (last_offset + last_size))) of="$new_gme" conv=notrunc oflag=append
        ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes skip=$((last_offset + last_size)) if="game.gme" count=$((offset - (last_offset + last_size))) of="$new_gme" conv=notrunc oflag=append
        [ $? -eq 0 ] || { echo "[ERROR] dd failed"; exit; }
    fi

    # extract the game's ARM binary using the outputs (offset + size) from analyze_gme.sh
    echo [INFO] Copying game binary \#$((idx))...
    echo [INFO] ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes if="game$((idx)).bin" count=$((size)) of="$new_gme" conv=notrunc oflag=append
    ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes if="game$((idx)).bin" count=$((size)) of="$new_gme" conv=notrunc oflag=append
    [ $? -eq 0 ] || { echo "[ERROR] dd failed"; exit; }

    num_zeros=$(( $((size)) - `wc -c < game$((idx)).bin` ))
    if [ $num_zeros -gt 0 ]; then
      echo [INFO] Filling with $num_zeros zero bytes after game binary \#$((idx))...
      echo [INFO] ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$num_zeros of="$new_gme" conv=notrunc oflag=append
      ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes if=/dev/zero count=$(( $((size)) - `wc -c < game$((idx)).bin` )) of="$new_gme" conv=notrunc oflag=append
      [ $? -eq 0 ] || { echo "[ERROR] dd failed"; exit; }
    else
      echo [INFO] No need to fill zero bytes after game binary \#$((idx))...
    fi

    idx=$((idx + 1))
    last_offset=$offset
    last_size=$size
done < binaries.csv

# copy rest of the original file
echo [INFO] ${DD_DIR}dd status=none iflag=skip_bytes,count_bytes skip="$((last_offset + last_size))" if="game.gme" conv=notrunc oflag=append of="$new_gme"
${DD_DIR}dd status=none iflag=skip_bytes,count_bytes skip="$((last_offset + last_size))" if="game.gme" conv=notrunc oflag=append of="$new_gme"
[ $? -eq 0 ] || { echo "[ERROR] dd failed"; exit; }

echo [INFO] Calculating md5sum of '$new_gme'...
md5sum "$new_gme"

# The patched_gme.gme should be renamed to the original file name;
# afterwards, it should be loaded on the pen (at your own risk!)
