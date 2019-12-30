#!/bin/bash
execCmd="python3 ../snowbirdopter.py"

echo "This bash script will execute single commands of snowbirdopter."

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing memory dump with single address..."
wholeCmd="$execCmd -c dump -a 0"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 10
else
    echo "[TEST PASSED]"
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing memory dump with start and stop addresses..."
wholeCmd="$execCmd -c dump -a 08010000 -e 0801001f"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 20
else
    echo "[TEST PASSED]"
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing memory dump with start and stop addresses (to a file)..."
dmpFileName="tmpdump.bin"
wholeCmd="$execCmd -c dump -a 08010000 -e 0801001f -f $dmpFileName"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 30
else
    if [ -f "$dmpFileName" ]; then
        dmpFileSize=$( du -b $dmpFileName | cut -f1 )
        echo "[INFO] Dump file size: $dmpFileSize"
        if [ "$dmpFileSize" -ne "32" ]; then
            echo "[ERROR] Unexpected dump file size."
            exit 31
        fi
        rm $dmpFileName
        echo "[TEST PASSED]"
    else
        echo "[ERROR] Dump file does not exist."
        exit 32
    fi
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing memory set value command..."
wholeCmd="$execCmd -c setvalue -a 08010000 -n DEADBEEF"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 40
else
    echo "[TEST PASSED]"
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Trying to build all examples..."

folderList=$(ls -d ../examples/*/)
for folder in $folderList
do
    if [ "$folder" == "../examples/include/" ]; then
        continue
    fi
    cd $folder
    make clean
    make
    if [ $? -ne 0 ]; then
        echo "[TEST FAILED] for folder $folder"
        exit 50
    else
        if [ -f "out.bin" ]; then
            echo "[INFO] Binary file does exist."
        else
            echo "[ERROR] Binary file does not exist."
            exit 51
        fi
        echo "[TEST PASSED]"
    fi
    cd ../../test
done

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing the load command..."

# expected to fail due to wrong alignment
wholeCmd="$execCmd -c load -a 08010001 -f ../examples/uart_hello_world/out.bin"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -eq 0 ]; then
    echo "[TEST FAILED]"
    exit 60
else
    echo "[TEST PASSED]"
fi

# should work as alignment is correct here
wholeCmd="$execCmd -c load -a 08010004 -f ../examples/uart_hello_world/out.bin"
echo "[INFO] Command: \"$wholeCmd\""
$wholeCmd
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 61
else
    echo "[TEST PASSED]"
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing execute command (includes the load command) with the UART echo example..."
whole1Cmd="$execCmd -c exec -a 08010000 -f ../examples/uart_echo_char/out.bin"
whole2Cmd="$execCmd -c rxl -a 0"
echo "[INFO] Command: \"${whole1Cmd} \&\& ${whole2Cmd}\""
${whole1Cmd} && ${whole2Cmd}
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 70
else
    echo "[TEST PASSED]"
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "[INFO] Testing the tx byte, rx line and the rx line commands..."

whole1Cmd="$execCmd -c txbrxl -b X -a 0" # FIXME: "-a 0" should not be required
whole2Cmd="$execCmd -c rxl -a 0" # FIXME: "-a 0" should not be required
echo "[INFO] Command: \"${whole1Cmd} \&\& ${whole2Cmd}\""
${whole1Cmd} && ${whole2Cmd}
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 80
else
    echo "[TEST PASSED]"
fi

whole1Cmd="$execCmd -c txbrxl -b Y -a 0" # FIXME: "-a 0" should not be required
whole2Cmd="$execCmd -c rxl -a 0" # FIXME: "-a 0" should not be required
echo "[INFO] Command: \"${whole1Cmd} \&\& ${whole2Cmd}\""
${whole1Cmd} && ${whole2Cmd}
if [ $? -ne 0 ]; then
    echo "[TEST FAILED]"
    exit 81
else
    echo "[TEST PASSED]"
fi

exit 0


