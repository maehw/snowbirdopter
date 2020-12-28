#!/bin/bash
execCmd="python3 ../snowbirdopter.py"
serialDev="/dev/ttyUSB0"

echo "This bash script will try to boot from NAND flash via the UART boot mode."

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Loading boot redirect example via serial..."
wholeCmd="$execCmd -p $serialDev -c exec -f ../examples/boot_redirect/out.bin -a 08010000 -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 10
fi

echo "[INFO] Selecting 'NAND flash boot'..."
wholeCmd="$execCmd -p $serialDev -c txbrxl -b n -a 0 -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 11
fi

echo "[TEST PASSED]"

