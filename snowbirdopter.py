import os
import argparse
import serial
import struct
import sys
from struct import *

class snowbirdopter:
    'Snowrbirdopter class to interact with the tiptoi''s snowbird processor'
    ser = None
    prompt = b'SNOWBIRD2-BIOS>#'

    def __init__(self, serport, verbose=True):
        try:
            self.ser = serial.Serial(serport, 38400, timeout=2, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, stopbits=1, xonxoff=0, rtscts=0)
        except serial.serialutil.SerialException:
            print(r"[DEBUG] Serial device is not available." )
            raise ValueError('Serial device is not available.')

        if verbose:
            print(r"[DEBUG] Serial port device name: '{}'".format(self.ser.name) )

    def __del__(self):
        pass
        #if self.ser is not None:
        #    self.ser.close()

    def readline(self, verbose=True):
        line = self.ser.readline()
        if verbose:
            print(r"[INFO] Read from serial: {}".format(line) )
        return True

    # Transmit a line byte per byte and wait for correct echo after each byte
    def trx_line(self, line, rxEcho=True, checkEcho=True):
        for k in range(0, len(line)):
            cTx = line[k].to_bytes(1, byteorder='big')
            self.ser.write(cTx)
            if rxEcho:
                cRx = self.ser.read(1)
                if checkEcho and (cTx != cRx):
                    print(r"[ERROR] Tx: {} != Rx: {}".format( cTx, cRx ))
                    return False
        return True

    # Receive until expected string appears or timeout occurs
    def rx_check_expected(self, exp):
        resp = self.ser.read_until(exp)
        if resp == exp:
            return True
        else:
            print(r"[ERROR] resp: {} != exp: {}".format( resp, exp ))
            return False

    # Implementation of the dump command; can optionally also dump to a binary file
    def dump(self, startAddr, endAddr, filepath=None, verbose=True):
        startAddr = startAddr.lower()
        endAddr = endAddr.lower()

        if verbose:
            if filepath:
                print(r"[DEBUG] dump from 0x{} to 0x{}, store in binfile '{}'".format(startAddr, endAddr, filepath) )
            else:
                print(r"[DEBUG] dump from 0x{} to 0x{}".format(startAddr, endAddr) )

        cmd = b'dump\r'
        if not self.trx_line(cmd):
            return False

        if not self.rx_check_expected(b'Input start addr(0x08000000):'):
            return False

        addr = startAddr.encode('ascii') + b'\r'
        if not self.trx_line(addr):
            return False

        if not self.rx_check_expected(b'Input end addr(0x08000000):'):
            return False

        addr = endAddr.encode('ascii') + b'\r'
        if not self.trx_line(addr):
            return False

        header = b'   Adress \t    0   \t     4    \t     8    \t      c\n'
        if not self.rx_check_expected(header):
            return False

        fp = None
        if filepath:
            fp = open(filepath, "wb")
            if not fp:
                return False

        line = True
        while line:
            line = self.ser.readline()
            if line == self.prompt:
                # Prompt appeared, the dump has finished.
                break
            else:
                line = line.decode("ascii").rstrip()
                
                rawData = line.split('\t', 5)
                if verbose:
                    print( r"[DEBUG] {}".format( '  '.join(rawData) ) )

                # further processing to store it in a binary file
                # skip address as the memory values are in consecutive order without gaps
                for i in range(1, len(rawData) ):
                    value = int(rawData[i], 16)
                    if fp:
                        fp.write(value.to_bytes(4, byteorder='little', signed=False))

        if fp:
            fp.close()

        # check last line again
        if not line == self.prompt:
            return False
        else:
            return True

    # Implementation of the setvalue command
    def setvalue(self, address, value, verbose=True):
        # TODO/FIXME: check word alignment!
        address = address.lower()
        value = value.lower()

        if verbose:
            print(r"[DEBUG] setvalue 0x{} at 0x{}".format(value, address) )

        cmd = b'setvalue\r'
        if not self.trx_line(cmd):
            return False

        if not self.rx_check_expected(b'Input addr(0xfffffff0):'):
            return False

        addr = address.encode('ascii') + b'\r'
        if not self.trx_line(addr):
            return False

        if not self.rx_check_expected(b'Input value(0xfffffff0):'):
            return False

        val = value.encode('ascii') + b'\r'
        if not self.trx_line(val):
            return False

        # concatenate expected result
        readbackMemory = b'Addr 0x' + address.encode('ascii') + b' value :0x' + value.encode('ascii') + b'\n'
        if not self.rx_check_expected(readbackMemory):
            return False
        
        if not self.rx_check_expected(self.prompt):
            return False
        
        return True

    # Implementation of the go command
    def go(self, address, verbose=True, readAfterGo=True):
        address = address.lower()

        if verbose:
            print(r"[DEBUG] go to address 0x{}".format(address) )

        cmd = b'go\r'
        if not self.trx_line(cmd):
            return False

        if not self.rx_check_expected(b'Input addr(0x08000000):'):
            return False

        addr = address.encode('ascii') + b'\r'
        if not self.trx_line(addr):
            return False

        if readAfterGo:
            self.readline(verbose=True)

        return True

    # Implementation of the download command
    def download(self, address, data, verbose=True):
        if verbose:
            print(r"[DEBUG] download to address 0x{}".format(address) )

        cmd = b'download\r'
        if not self.trx_line(cmd):
            return False
        
        if not self.rx_check_expected(b'Input down addr(0x08000000):'):
            return False
        
        txAddress = address.encode('ascii')
        if not self.trx_line( txAddress + b'\r' ):
            return False

        if not self.rx_check_expected( b'addr :0x' + txAddress + b'\nSelect your file:' ):
            return False

        payloadLen = len(data)
        downloadLen = 6 + payloadLen # 4 bytes length + 2 bytes checksum + length of payload data
        #if verbose:
        print( r"[DEBUG] payload length: {}, overall download length: {}".format( payloadLen, downloadLen ) )

        try:
            txDownloadLen = downloadLen.to_bytes(4, byteorder='little')
        except:
            print( "[ERROR] Unable to convert length to 16 bit value to be transmitted." )
            return False

        # transmit the size
        if not self.trx_line(txDownloadLen, rxEcho=False):
            return False

        # transmit the payload data
        if not self.trx_line(data, rxEcho=False):
            return False

        # calculate the checksum (16 bit)
        checkSum = sum(data)
        if verbose:
            checkSum16Bits = checkSum % (2**16)

        if verbose:
            print( r"[DEBUG] checkSum={}, checkSum16Bits={}".format( checkSum, checkSum16Bits ) )
        try:
            txCheckSum = checkSum16Bits.to_bytes(2, byteorder='little')
        except Exception as ex:
            print( r'[ERROR] Unable to calculate checksum ("{}", value: {}).'.format(ex, checkSum16Bits) )
            return False
        if verbose:
            print( r"[DEBUG] checkSum={}, txCheckSum={}".format( checkSum, txCheckSum ) )

        # transmit the calculated checksum
        if not self.trx_line(txCheckSum, rxEcho=False):
            return False

        if not self.rx_check_expected(b'Strat check, Wait...'):
            return False

        self.readline(verbose=verbose) # read checksum line, TODO: compare returned checksum

        if not self.rx_check_expected(b'Down OK!\n'):
            return False

        return True

    # Load contents of a binary file to specific memory region on the target based on the native "download" command
    def load_binfile(self, startAddr, filepath, verbose=True):
        address = startAddr
        addressAsNum = int(startAddr, 16)
        
        if addressAsNum % 4 != 0:
            print( "[ERROR] Address must be aligned but it's not." )
            return False

        # TODO: add progress bar; calculation of estimated remaining time

        if verbose:
            print( r"[DEBUG] load_binfile('{}' at 0x{:08x})".format(filepath, addressAsNum) )

        statinfo = os.stat(filepath)
        alignment = statinfo.st_size%4
        if verbose:
            print( r"[DEBUG] File size: {}".format(statinfo.st_size) )

        with open(filepath, "rb") as fp:
            data = fp.read()
            if not self.download(address, data):
                print("[ERROR] Download failed.")
                return False

        if not self.rx_check_expected(self.prompt):
            return False

        return True

    # Receive a single byte/character from the serial (but do not have a look at the content and do not return it)
    def rx_byte(self, verbose=True):
        cRx = self.ser.read(1)

        if verbose:
            print(r"[INFO] Rx: {}".format( cRx ))

        if cRx == b'':
            return False
        else:
            return True

    # Receive a single byte/character from the serial
    def tx_byte(self, value, verbose=True):
        cTx = value.encode('ascii')

        if verbose:
            print(r"[INFO] Tx: {}".format( cTx ))

        if self.ser.write(cTx):
            return True
        else:
            return False

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='%(prog)s')

    parser.add_argument('-p', action="store", default='/dev/ttyUSB0', 
                    dest='serport',
                    help="serial device port name (e.g. '/dev/ttyUSB0' or 'COM1')")

    parser.add_argument('-c', action="store", default=False,
                    required=True,
                    dest='command',
                    help='command (dump, setval[ue], go, load, exec, txb, rxb, trxb, txbrxl)')

    parser.add_argument('-a', action="store", default=False,
                    required=True,
                    dest='address',
                    help="start address as hex string, without '0x' prefix")

    parser.add_argument('-e', action="store", default=False,
                    dest='endAddress',
                    help="end address as hex string, without '0x' prefix")

    parser.add_argument('-n', action="store", default=False,
                    dest='value',
                    help="value to be set in setval[ue] command, as hex string, without '0x' prefix")

    parser.add_argument('-b', action="store", default=False,
                    dest='txbyte',
                    help='byte to be transmitted in txb command')

    parser.add_argument('-f', action="store", default=False,
                    dest='file',
                    help='path to a binary file')

    parser.add_argument('-v', action="store", default=True,
                    dest='verbosity',
                    help='print detailed output')

    parser.add_argument('--version', action='version',
                        version='%(prog)s 0.2')

    args = parser.parse_args()
    #print(args)

    cmd = args.command.lower()
    address = "{:08x}".format( int(args.address, 16) )
    
    if args.endAddress:
        endAddress = "{:08x}".format( int(args.endAddress, 16) )
    else:
        endAddress = address

    if args.value:
        value = "{:08x}".format( int(args.value, 16) )
    
    fname = None
    verbose=args.verbosity

    if args.file:
        # check if the file exists when it is going to be loaded (and optionally also executed)
        if cmd == 'load' or cmd == 'exec':
            if os.path.isfile(args.file):
                if verbose:
                    print(r"[DEBUG] File '{}' exists.".format(args.file))
                fname = args.file
            else:
                print(r"[ERROR] File '{}' does not exist.".format(args.file))
                sys.exit(12)
        else:
            fname = args.file

    try:
        inst = snowbirdopter(serport=args.serport, verbose=verbose)

        if cmd == 'go':
            if inst.go(address, verbose):
                if verbose:
                    print("[INFO] Go command probably succeeded.")
            else:
                print("[ERROR] Go command failed.")
                sys.exit(1)

        elif cmd == 'dump':
            if inst.dump(address, endAddress, fname, verbose):
                if verbose:
                    print("[INFO] Dump succeeded.")
            else:
                print("[ERROR] Dump failed.")
                # sys.exit(2) # FIXME

        elif cmd == 'setvalue' or cmd == 'setval':
            if inst.setvalue(address, value, verbose):
                if verbose:
                    print("[INFO] Setting value succeeded.")
            else:
                print("[ERROR] Setting value failed.")
                sys.exit(3)

        elif cmd == 'load' or cmd == 'exec': # load data/code (and eventually also execute code)
            if inst.load_binfile(address, fname, verbose):
                print("[INFO] Loading binfile succeeded.")
                if cmd == 'exec':
                    if inst.go(address):
                        if verbose:
                            print("[INFO] Executing binfile succeeded.")
                    else:
                        print("[ERROR] Executing binfile failed.")
            else:
                print("[ERROR] Loading binfile failed.")
                sys.exit(4)

        elif cmd == 'txb': # transmit byte
            if inst.tx_byte(args.txbyte, verbose):
                if verbose:
                    print("[INFO] Sending byte succeeded.")
            else:
                print("[ERROR] Sending byte failed.")
                sys.exit(5)

        elif cmd == 'rxb': # receive byte
            if inst.rx_byte():
                print("[INFO] Receiving byte succeeded.")
            else:
                print("[ERROR] Receiving byte failed.")
                sys.exit(6)

        elif cmd == 'trxb': # transmit byte and immediately receive byte
            if inst.tx_byte(args.txbyte, verbose):
                if inst.rx_byte():
                    if verbose:
                        print("[INFO] Transceiving byte succeeded.")
                else:
                    print("[ERROR] Transceiving byte failed.")
                    sys.exit(7)
            else:
                print("[ERROR] Transceiving byte failed.")
                sys.exit(8)

        elif cmd == 'txbrxl': # transmit byte and receive line
            nLines = 1        
            if args.value:
                nLines = int(args.value)
            if inst.tx_byte(args.txbyte, verbose):
                for k in range(0, nLines):
                    if not inst.readline(verbose=verbose):
                        print("[ERROR] Transceiving byte failed.")
                        sys.exit(8)
                if verbose:
                    print("[INFO] Transceiving byte succeeded.")    
            else:
                print("[ERROR] Transceiving byte failed.")
                sys.exit(9)

        elif cmd == 'rxl': # receive line(s), without any transmit
            nLines = 1        
            if args.value:
                nLines = int(args.value)
            for k in range(0, nLines):
                if not inst.readline(verbose=verbose):
                    print("[ERROR] Receiving line(s) failed.")
                    sys.exit(10)
            if verbose:
                print("[INFO] Receiving line(s) succeeded.")    

        else:
            print(r"[ERROR] Unrecognized command.")
            sys.exit(11)

        sys.exit(0)

    except Exception as ex:
        print( r'[ERROR] Internal error occured. Exception: "{}".'.format(ex) )

        sys.exit(99)

