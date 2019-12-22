import os
import argparse
import serial
from struct import *

class snowbirdopter:
    'Snowrbirdopter class to interact with the tiptoi''s snowbird processor'
    ser = None
    prompt = b'SNOWBIRD2-BIOS>#'

    def __init__(self, serport):
        self.ser = serial.Serial(serport, 38400, timeout=2, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, stopbits=1, xonxoff=0, rtscts=0)
        print(r"[DEBUG] Serial port device name: '{}'".format(self.ser.name) )

        # if immediately switched on after the serial interface has been opened, the first prompt should be read from the serial RX buffer before sending any command
        #switchingOn = False
        #if switchingOn:
        #    welcomePrompt = self.ser.read(512)
        #    print(r"{}".format( welcomePrompt ) )

    def __del__(self):
        self.ser.close()

    def readline(self):
        line = self.ser.readline()
        print(r"Read from serial: {}".format(line) )
        return True

    # Transmit a line byte per byte and wait for correct echo after each byte
    def trx_line(self, line):
        for k in range(0, len(line)):
            cTx = line[k].to_bytes(1, byteorder='big')
            self.ser.write(cTx)
            cRx = self.ser.read(1)
            if cTx != cRx:
                print(r"Tx: {} != Rx: {}".format( cTx, cRx ))
                return False
        return True

    # Receive until expected string appears or timeout occurs
    def rx_check_expected(self, exp):
        resp = self.ser.read_until(exp)
        if resp == exp:
            return True
        else:
            print(r"resp: {} != exp: {}".format( resp, exp ))
            return False

    # Implementation of the dump command; can optionally also dump to a binary file
    def dump(self, startAddr, endAddr, filepath=None):
        startAddr = startAddr.lower()
        endAddr = endAddr.lower()

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
    def setvalue(self, address, value):
        address = address.lower()
        value = value.lower()

        # TODO/FIXME: check word alignment!
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
    def go(self, address):
        address = address.lower()

        print(r"[DEBUG] go to address 0x{}".format(address) )
        cmd = b'go\r'

        if not self.trx_line(cmd):
            return False

        if not self.rx_check_expected(b'Input addr(0x08000000):'):
            return False

        addr = address.encode('ascii') + b'\r'
        if not self.trx_line(addr):
            return False

        self.readline()

        return True

    # Load contents of a binary file to specific memory region on the target
    def load_binfile(self, startAddr, filepath):
        address = startAddr
        addressAsNum = int(startAddr, 16)
        # TODO/FIXME: check word alignment!
        # TODO: add progress bar; calculation of estimated remaining time

        print( r"[DEBUG] load_binfile('{}' at 0x{:08x})".format(filepath, addressAsNum) )
        
        statinfo = os.stat(filepath)
        alignment = statinfo.st_size%4
        print( r"[DEBUG] File size: {}".format(statinfo.st_size) )

        if alignment != 0:
            return False

        with open(filepath, "rb") as fp:
            word = fp.read(4)
            while word:
                value = next(iter(unpack('I', word)))
                valueAsStr = "{:08x}".format(value)
                address = "{:08x}".format(addressAsNum)
                if not self.setvalue(address, valueAsStr):
                    print("[ERROR] Setting value failed.")
                    return False
                word = fp.read(4)
                addressAsNum += 4
        return True

    # Receive a single byte/character from the serial
    def rx_byte(self):
        cRx = self.ser.read(1)
        print(r"Rx: {}".format( cRx ))
        if cRx == b'':
            return False
        else:
            return True

    # Receive a single byte/character from the serial
    def tx_byte(self, value):
        cTx = value.encode('ascii')
        print(r"Tx: {}".format( cTx ))
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
                    help='start address')

    parser.add_argument('-e', action="store", default=False,
                    dest='endAddress',
                    help='end address')

    parser.add_argument('-n', action="store", default=False,
                    dest='value',
                    help='value to be set in setval[ue] command')

    parser.add_argument('-b', action="store", default=False,
                    dest='txbyte',
                    help='Byte to be transmittedin txb command')

    parser.add_argument('-f', action="store", default=False,
                    dest='file',
                    help='path to a binary file')

    parser.add_argument('--version', action='version',
                        version='%(prog)s 0.1')

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
    if args.file:
        # check if the file exists when it is going to be loaded (and optionally also executed)
        if cmd == 'load' or cmd == 'exec':
            if os.path.isfile(args.file):
                print(r"[DEBUG] File '{}' exists.".format(args.file))
                fname = args.file
            else:
                print(r"[ERROR] File '{}' does not exist.".format(args.file))
        else:
            fname = args.file

    inst = snowbirdopter(serport=args.serport)

    if cmd == 'go':
        if inst.go(address):
            print("[INFO] Go command succeeded.")
        else:
            print("[ERROR] Go command failed.")

    elif cmd == 'dump':
        if inst.dump(address, endAddress, fname):
            print("[INFO] Dump succeeded.")
        else:
            print("[ERROR] Dump failed.")

    elif cmd == 'setvalue' or cmd == 'setval':
        if inst.setvalue(address, value):
            print("[INFO] Setting value succeeded.")
        else:
            print("[ERROR] Setting value failed.")

    elif cmd == 'load' or cmd == 'exec':
        if inst.load_binfile(address, fname):
            print("[INFO] Loading binfile succeeded.")
            if cmd == 'exec':
                if inst.go(address):
                    print("[INFO] Executing binfile succeeded.")
                else:
                    print("[ERROR] Executing binfile failed.")
        else:
            print("[ERROR] Loading binfile failed.")

    elif cmd == 'txb': # transmit byte
        if inst.tx_byte(args.txbyte):
            print("[INFO] Sending byte succeeded.")
        else:
            print("[ERROR] Sending byte failed.")

    elif cmd == 'rxb': # receive byte
        if inst.rx_byte():
            print("[INFO] Receiving byte succeeded.")
        else:
            print("[ERROR] Receiving byte failed.")

    elif cmd == 'trxb': # transmit byte and immediately receive byte
        if inst.tx_byte(args.txbyte):
            if inst.rx_byte():
                print("[INFO] Transceiving byte succeeded.")
            else:
                print("[ERROR] Transceiving byte failed.")
        else:
            print("[ERROR] Transceiving byte failed.")

    elif cmd == 'txbrxl': # transmit byte and receive line
        nLines = 1        
        if args.value:
            nLines = int(args.value)
        if inst.tx_byte(args.txbyte):
            for k in range(0, nLines):
                if not inst.readline():
                    print("[ERROR] Transceiving byte failed.")
            print("[INFO] Transceiving byte succeeded.")    
        else:
            print("[ERROR] Transceiving byte failed.")

    elif cmd == 'rxl': # receive line(s), without any transmit
        nLines = 1        
        if args.value:
            nLines = int(args.value)
        for k in range(0, nLines):
            if not inst.readline():
                print("[ERROR] Receiving line(s) failed.")
        print("[INFO] Receiving line(s) succeeded.")    

    else:
        print(r"[ERROR] Unrecognized command.")

