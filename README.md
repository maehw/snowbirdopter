# snowbirdopter

The **snowbirdopter** is a tool which can be used to get memory dumps from the tiptoi pen[^0], to load arbitrary memory (code and data) into the pen's processor's memory and to execute binaries. This can either be done via UART boot mode or via USB/SCSI in mass boot mode for firmware update (not the "normal" mass boot mode). It can also be used to exchange serial data (transmit and receive) over the UART interface with the pen.

It can be used to find out more about the processor and the the whole tiptoi pen's execution environment, e.g. how embedded games can be analyzed, debugged or developed. The communication with the pen is based on its UART boot mode (details in the "Usage" section below).

***IMPORTANT: This software has been developed on an information basis compiled from information freely available on the Internet and confirmed by own experiments. It is provided without any guarantee and may be erroneous! We are not responsible when you brick your tiptoi pen!***



## Contributing

Feel free to make contributions to the source code to improve snowbirdopter by fixing bugs and adding new functionalities or examples! Please also check the [github issues page](https://github.com/maehw/snowbirdopter/issues) for known issues and enhancement requests.



## Dependencies

snowbirdopter is a command-line tool based on the [Python3](http://python.org/) scripting language, i.e. you currently need a Python3 interpreter running on your machine.

It also depends on the [pySerial](https://pyserial.readthedocs.io/en/latest/pyserial.html) package which It provides backends for Python running on Windows, OSX, Linux and others. There are various ways to install the package, which are described on their website.

If the package is not installed you will get the following or a similar error message:

```
   Traceback (most recent call last):
     File "snowbirdopter.py", line 3, in <module>
       import serial
   ModuleNotFoundError: No module named 'serial'
```

If you want to do compile, load and execute your own source code, you'll need an ARM cross-compiler. The installation process is described in another section below.


## Usage

To show the **snowbirdopter**'s usage enter:

```
python3 snowbirdopter.py -h
```

The output should look similar to:

```
usage: snowbirdopter.py [-h] [-p SERPORT] [-s SCSIDEV] -c COMMAND [-a ADDRESS] [-e ENDADDRESS] [-n VALUE] [-b TXBYTE] [-f FILE]
                        [-v VERBOSITY] [--version]

snowbirdopter.py

optional arguments:
  -h, --help     show this help message and exit
  -p SERPORT     serial device port name (e.g. '/dev/ttyUSB0' or 'COM1')
  -s SCSIDEV     generic SCSI device file name (e.g. '/dev/sg2')
  -c COMMAND     command (dump, setval[ue], go, load, exec, txb, rxb, trxb, txbrxl)
  -a ADDRESS     start address as hex string, without '0x' prefix
  -e ENDADDRESS  end address as hex string, without '0x' prefix
  -n VALUE       value to be set in setval[ue] command, as hex string, without '0x' prefix
  -b TXBYTE      byte to be transmitted in txb command
  -f FILE        path to a binary file
  -v VERBOSITY   print detailed output
  --version      show program's version number and exit
```


### Commands

The currently supported commands are:

| command      | addresss required? | description                                                  |
| ------------ |:------------------:| ------------------------------------------------------------ |
| `dump`       | ✓                  | Dump memory from a specific address or address range<br />(dumps to *stdout* in a human-readable format, optionally also dumps to a raw binary file) |
| `setval[ue]` | ✓                  |  Set a 32-bit word at a specific address (given by `-a`)     |
| `go`         | ✓                  |  Execute the code located at a given address (address given by `-a`) |
| `load`       | ✓                  |  Load a binary executable from the file system to the target (at address given by `-a`) |
| `exec`       | ✓                  |  Load a binary executable from the file system to the target and execute it |
| `txb`        | ✗                  |  Transmit a single byte (`-b`) to the serial                    |
| `rxb`        | ✗                  |  Receive a single byte from the serial                        |
| `trxb`       | ✗                  |  Transmit a single byte (`-b`) to serial and immediately read back a single response byte from the serial |
| `txbrxl`     | ✗                  |  Transmit a single byte (`-b`) to serial and immediately read back one or several lines from the serial |
| `rxl`        | ✗                  |  Read one or several lines from the serial                    |



## Tiptoi special pins

The following information is taken from https://github.com/entropia/tip-toi-reveng/wiki/PEN-Hardware-Details:

| Pin             | Function                                                     |
| --------------- | ------------------------------------------------------------ |
| GPIO13 (pin 39) | UART TX* pin + mass storage boot selector pin<br />(pull to low by a 1 kOhm resistor to enter mass boot mode for firmware update) |
| GPIO9 (pin 37)  | UART boot selector pin<br />(pulled to low by a 1 kOhm resistor to enter UART boot mode) |
| GPIO12 (pin 36) | UART RX* pin                                                 |

*TX/RX as seen from the device, i.e. RX/TX as seen from the PC.

To enter and manually use boot mode:

* Connect your USB/serial converter to the UART TX and RX pins.
* Open a serial terminal program, e.g. *moserial*, *HTerm*, etc. and connect with *38400 baud*, *8N1* and *no handshakes*.
* Pull GPIO9 high.
* Power the tiptoi pen.
* The string `"SNOWBIRD2-BIOS>#"` is sent via UART TX pin immediately after start-up.



## Serial connection

Connect your USB/serial converter to the tiptoi pen (with 3.3V logic levels!). Enter the pen's UART boot mode (*at your own risk*!).

Find out the serial device's port name on your system, e.g. "/dev/ttyUSB0" or "COM1". Under Windows this can be done by opening the *device manager*. Under Linux you can open a command line window, go to the */dev/* directory and list all USB tty devices, i.e. `ls -al ttyUSB*`.

The serial port settings *38400 baud*, *8N1* and *no handshakes* are automatically configured by the Python script.



If snowbirdopter reports
```
[ERROR] Internal error occured. Exception: "Serial device is not available."
```
and you are sure that the given device exists you should check the access rights for your serial device's port and change them if necessary, e.g. execute `sudo chmod 666 /dev/ttyUSB0`. Please check [the web](https://askubuntu.com/questions/58119/changing-permissions-on-serial-port) for alternatives like `udev` rules or permission groups.




## How to build a loadable and executable binary

You will find pre-compiled binaries in the examples/ subfolder. To modify them or run your own code you'll need to get an ARM cross-compiler, e.g. GCC. For Linux the process looks as follows:

```
sudo apt install binutils-arm-linux-gnueabi
```

For MacOS you can use the following command in the terminal:

```
brew install gcc-arm-embedded
```

Build the "hello world" example:

```
cd examples/standalone/bootrom_uart_hello_world/
make clean
make
```

Done! You're now able to load and execute it on the target, see next section.



## How to load and execute a binary (via serial)

Before executing your first binary, it's recommended to check if the connection to the pen works by dumping the value at address `0x00000000` (addresses need to be given given as hex strings; they do not need to have a "0x" prefix, but they can):

```
python3 snowbirdopter.py -p /dev/ttyUSB0 -c dump -a 0
```

The output should look similar to:

```
[INFO] 0x08100000:  0xea000020
```

Using a different verbosity level and running under the MacOS terminal this could also look like the following:

```
% python3 snowbirdopter.py -c dump -a 0 -p /dev/tty.SLAB_USBtoUART -v 1
[DEBUG] Platform: Darwin
[WARNING] Not run under Linux. SCSI commands won't be supported on this platform.
[DEBUG] Serial device port name: '/dev/tty.SLAB_USBtoUART'
[DEBUG] dump from 0x00000000 to 0x00000000
[INFO] 0x00000000:  0xea000006
[DEBUG] Return value from specific dump: True
[INFO] Dump succeeded.
```

Load the previously built "hello world" example mentioned to the target and execute it by using the following command line:

```
python3 snowbirdopter.py -p /dev/ttyUSB0 -c exec -f ./examples/uart_hello_world/out.bin -a 08010000
```

The output should look similar to:

```
[DEBUG] File './examples/uart_hello_world/out.bin' exists.
[DEBUG] Serial port device name: '/dev/ttyUSB0'
[DEBUG] load_binfile('./examples/uart_hello_world/out.bin' at 0x08010000)
[DEBUG] File size: 120
[DEBUG] setvalue 0xeaffffff at 0x08010000
[DEBUG] setvalue 0xeb000000 at 0x08010004
...
[INFO] Loading binfile succeeded.
[DEBUG] go to address 0x08010000
Read from serial: b'Hello Tiptoi! Hello world!\n'
[INFO] Executing binfile succeeded.
```

**Important note**: The pen won't be responsive to further commands and will need to be power-cycled.

There are already some more examples in the *examples/* subdirectory. Feel free to analyze, execute them on the pen and modify them according to your needs.


## How to interact with executables (loaded via serial)

There's some code in the examples that demonstrates how to interact with an executable using snowbirdopter's command.
There's always the way for your code to send something via the serial. Not only that: you can also read characters from the serial - this allows your program to wait or even influence the program flow dependent on the user's input via serial.

Here's an example:

Go to the `/examples/standalone/boot_redirect` directory. Build (`make`) and load the executable:

```
% python3 ../../../snowbirdopter.py -c exec -a 08010000 -p /dev/tty.SLAB_USBtoUART -f out.bin
[WARNING] Not run under Linux. SCSI commands won't be supported on this platform.
[INFO] Loading binfile succeeded.
[DEBUG] go to address 0x08010000
[INFO] Read from serial: b'Boot mode register: 02000001. Boot will be redirected. Which bode mode to use? m/M=massboot, u/U=usbboot, s/S=SPI flash boot, n/N=NAND flash boot (default).\n'
```

The last line of the printed output signals that the executable is waiting for the user's input - in order to decide which boot mode to use.

Inspecting the code gives us some insighets:

```
    bootrom_uart_puts(". Boot will be redirected. Which bode mode to use? ");
    bootrom_uart_puts("m/M=massboot, u/U=usbboot, s/S=SPI flash boot, n/N=NAND flash boot (default).\n");

    /* Wait for user input */
    bootrom_uart_getc(&nWord);
```

Calling the function `bootrom_uart_get()` in your code will indeed let the processor block until a character has been received via the serial. In order to send the response we could either open a serial terminal, send the character and wait for the next output. Instead we can call snowbirdopter again in order to do that exact thing. Let's send the character `n` by using command `txbrxl` (send a single byte, but receive multiple lines as response) and specifying the character wiht option `-b`. As we want to see what's going on, we also specify verbosity level 1 by using `-v 1`:

```
% python3 ../../../snowbirdopter.py -c txbrxl -b n -p /dev/tty.SLAB_USBtoUART -v 1
[DEBUG] Platform: Darwin
[WARNING] Not run under Linux. SCSI commands won't be supported on this platform.
[DEBUG] Serial device port name: '/dev/tty.SLAB_USBtoUART'
[INFO] Tx: 'b'n''
[INFO] Read from serial: b'Trying to boot via NAND flash.\n'
[INFO] Transceiving byte succeeded.
```

Next, we should hear the tiptoi pen start sound - it's now ready to play as it has re-booted from NAND flash as in normal operation as if we just had pressed the power button on it.

Finally having another glimpse at the code helps us understand what has happened and why:

```
(...)
        case 'n':
        case 'N':
        default:
            bootrom_uart_puts("Trying to boot via NAND flash.\n");
            bootrom_nandflash_boot();
            break;
    }

    /* Program flow should not reach this line */
    bootrom_uart_puts("Unexpectedly continued execution to this point.\n");
```


## How to analyze binary files

In general, you can create hex dumps of binary files. The `xxd` tool allows you to view the binary content with one 32-bit word per line:

```
xxd -ps -c 4 -e:4 ./examples/uart_hello_world/out.bin
```

```
00000000: eaffffff  ....
00000004: eb000000  ....
00000008: eafffffe  ....

(...)
```



As this might not be very convenient, there are some more elaborated ways to analyze a binary file.

Disassemble a binary file which has been built for the ARM architecture, e.g. one of our compiled examples:

```
arm-none-eabi-objdump --architecture=arm -b binary -D ./examples/uart_hello_world/out.bin
```

```
./examples/uart_hello_world/out.bin:     file format binary

Disassembly of section .data:

00000000 <.data>:
   0:	eaffffff 	b	0x4
   4:	eb000000 	bl	0xc
   8:	eafffffe 	b	0x8
   c:	e92d4800 	push	{fp, lr}
(...)
```



Of course, you can also use your favorite reverse engineering framework for disassembly and analysis, like *radare2* or *Ghidra* or ...



## What about the strange name of the tool?

The name **snowbirdopter** derives from the codename of the tiptoi pen's ARM processor[^1]  *snowbird* and the greek word *pteron* "wing". The snowbirdopter shall be used to let the snowbird's wings move so that it can fly[^2]! In addition, in the English language an *opter* is someone who opts, or makes a choice[^3] - e.g. to run own open-source software on the target.


[^0]: [tip-toi-reveng](https://github.com/entropia/tip-toi-reveng) github repository

[^1]: probably with an ARM926EJ-S core

[^2]: Have you ever heard about [ornithopters](https://en.wikipedia.org/wiki/Ornithopter)?

[^3]: [Wiktionary: opter](https://en.wiktionary.org/wiki/opter)
