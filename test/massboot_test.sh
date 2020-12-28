#!/bin/bash
execCmd="python3 ../snowbirdopter.py"
serialDev="/dev/ttyUSB0"
scsiDev="/dev/sg2"

echo "This bash script will try to enter massboot and test SCSI commands."

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Loading boot redirect example via serial..."
wholeCmd="$execCmd -p $serialDev -c exec -f ../examples/boot_redirect/out.bin -a 08010000 -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 10
fi

echo "[INFO] Selecting 'massboot'..."
wholeCmd="$execCmd -p $serialDev -c txbrxl -b m -a 0 -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 11
fi

echo "[TEST PASSED]"

read -n 1 -s -r -p "[INFO] Attach device's USB port. Then press any key to continue"
echo

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing memory dump. Sleeping for 3 seconds..."
sleep 3
wholeCmd="$execCmd -c dump -s $scsiDev -a 0 -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 20
else
    echo "[TEST PASSED]"
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Loading boot redirect example via SCSI..."
wholeCmd="$execCmd -c exec -f ../examples/boot_redirect/out.bin -a 08010000 -s $scsiDev -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 30
fi

echo "[INFO] Selecting 'UART boot'..."
wholeCmd="$execCmd -p $serialDev -c txbrxl -b l -a 0 -v 1"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 31
fi

echo "[TEST PASSED]"

exit 0


