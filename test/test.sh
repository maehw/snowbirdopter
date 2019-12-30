#!/bin/bash

echo "[INFO] Make sure that the device's USB port is disconnected and the pen is reset to UART boot mode."
echo "[INFO] Performing tests. You should see activity on the USB/serial converter."
echo "[INFO] stdout and stderr are piped to /dev/null and therefore not seen."
echo "[INFO] Please wait for the test result..."

./unit_tests.sh >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "[TESTS FAILED]"
else
    echo "[TESTS PASSED]"
fi

