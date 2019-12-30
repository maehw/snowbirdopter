#!/bin/bash
echo "NAND flash boot devices (normal operation mode)"
echo "---------------------------------------------------------------------------"
nandFlashBootUsb=$(usb-devices | grep -B3 -A4 -i "Manufacturer=tiptoi")
if [ -z "$nandFlashBootUsb" ]; then
    echo "(empty output)"
else
    usb-devices | grep -B3 -A4 -i "Manufacturer=tiptoi"
fi
echo

echo "USB boot devices"
echo "---------------------------------------------------------------------------"

usbBootUsb=$(usb-devices | grep -B2 -A2 -i "Vendor=04d6 ProdID=0665")
if [ -z "$usbBootUsb" ]; then
    echo "(empty output)"
else
    usb-devices | grep -B2 -A2 -i "Vendor=04d6 ProdID=0665"
fi
echo

echo "Mass boot devices"
echo "---------------------------------------------------------------------------"

massBootUsb=$(usb-devices | grep -B2 -A2 -i "Vendor=04d6 ProdID=038d")
if [ -z "$massBootUsb" ]; then
    echo "(empty output)"
else
    usb-devices | grep -B2 -A2 -i "Vendor=04d6 ProdID=038d"
fi

