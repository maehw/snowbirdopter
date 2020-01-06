# snowbirdopter

The **snowbirdopter** is a tool which can be used to get memory dumps from the tiptoi pen[^0], to load arbitrary memory (code and data) into the pen's processor's memory and to execute binaries. This can either be done via UART boot mode or via USB/SCSI in mass boot mode. It can also be used to exchange serial data (transmit and receive) over the UART interface with the pen.

It can be used to find out more about the processor and the the whole tiptoi pen's execution environment, e.g. how embedded games can be analyzed, debugged or developed. The communication with the pen is based on its UART boot mode (details in the "Usage" section below). 

***IMPORTANT: This software has been developed on an information basis compiled from information freely available on the Internet and confirmed by own experiments. It is provided without any guarantee and may be erroneous! We are not responsible when you brick your tiptoi pen!***



## Usage

snowbirdopter is a command-line tool based on the Python3 scripting language, i.e. you currently need a Python3 interpreter running on your machine.

If you get the following error message, you need to install the Serial Module for Python3 at first:
```
   Traceback (most recent call last):
     File "snowbirdopter.py", line 3, in <module>
       import serial
   ModuleNotFoundError: No module named 'serial'
```

You can install the required Serial Module by the following commands:
```
sudo apt-get update
sudo apt-get install python3-serial
```


To show the **snowbirdopter**'s usage enter:

```
python3 snowbirdopter.py -h
```

Feel free to make contributions to the source code to improve snowbirdopter by fixing bugs and adding new functionalities or examples!



### Commands

The currently supported commands are:

| command    | description                                                  |
| ---------- | ------------------------------------------------------------ |
| dump       | Dump memory from a specific address or address range<br />(dumps to *stdout* in a human-readable format, optionally also dumps to a binary file) |
| setval[ue] | Set a 32-bit word at a specific address                      |
| go         | Execute the code located at a given address (address given by -a) |
| load       | Load a binary executable from the file system to the target (at address given by -a) |
| exec       | Load a binary executable from the file system to the target and execute it |
| txb        | Transmit a single byte (-b) to the serial                    |
| rxb        | Receive a single byte from the serial                        |
| trxb       | Transmit a single byte (-b) to serial and immediately read back a single byte from the serial |
| txbrxl     | Transmit a single byte (-b) to serial and immediately read back one or several lines from the serial |
| rxl        | Read one or several lines from the serial                    |

### Serial connection

Connect your USB/serial converter to the tiptoi pen (with 3.3V logic levels!). Enter the pen's UART boot mode, a detailed description can be found in [this tip-toi-reveng wiki article](https://github.com/entropia/tip-toi-reveng/wiki/PEN-Hardware-Details).

Find out the serial device's port name on your system, e.g. "/dev/ttyUSB0" or "COM1".

The serial port settings *38400 baud*, *8N1* and *no handshakes* are automatically configured by the Python script.



## How to build a loadable and executable binary

Get an ARM cross-compiler, e.g. GCC. For Linux the process looks as follows:

```
sudo apt install binutils-arm-linux-gnueabi
```

Build the "hello world" example:

```
cd examples/uart_hello_world/
make clean
make
```

Done!



## How to load and execute a binary (via serial)

Before executing your first binary, it's recommended to check if the connection to the pen works by dumping the value at address `0x00000000` (addresses need to be given given as hex strings; they do not need to have a "0x" prefix, but they can):

```
python3 snowbirdopter.py -p /dev/ttyUSB0 -c dump -a 0
```

The output should look similar to:

> [DEBUG] Serial port device name: '/dev/ttyUSB0'
> [DEBUG] dump from 0x00000000 to 0x00000000
> 0x00000000:  0xea000006
> [INFO] Dump succeeded.



Load the previously built "hello world" example mentioned to the target and execute it by using the following command line:

```
python3 snowbirdopter.py -p /dev/ttyUSB0 -c exec -f ./examples/uart_hello_world/out.bin -a 08010000
```

The output should look similar to:

> [DEBUG] File './examples/uart_hello_world/out.bin' exists.
> [DEBUG] Serial port device name: '/dev/ttyUSB0'
> [DEBUG] load_binfile('./examples/uart_hello_world/out.bin' at 0x08010000)
> [DEBUG] File size: 120
> [DEBUG] setvalue 0xeaffffff at 0x08010000
> [DEBUG] setvalue 0xeb000000 at 0x08010004
> ...
> [INFO] Loading binfile succeeded.
> [DEBUG] go to address 0x08010000
> Read from serial: b'Hello Tiptoi! Hello world!\n'
> [INFO] Executing binfile succeeded.

Note: The pen won't be responsive to further commands and will need to be power-cycled.

There are already some more examples in the *examples/* subdirectory. Feel free to analyze, execute them on the pen and modify them for your needs.



## How to analyze binary files

In general, you can create hex dumps of binary files. The `xxd` tool allows you to view the binary content with one 32-bit word per line:

```
xxd -ps -c 4 -e:4 ./examples/uart_hello_world/out.bin 
```

> ```
> 00000000: eaffffff  ....
> 00000004: eb000000  ....
> 00000008: eafffffe  ....
> 
> (...)
> ```



As this might not be very convenient, there are some more elaborated ways to analyze a binary file.

Disassemble a binary file which has been built for the ARM architecture, e.g. one of our compiled examples:

```
arm-none-eabi-objdump --architecture=arm -b binary -D ./examples/uart_hello_world/out.bin
```

> ```
> ./examples/uart_hello_world/out.bin:     file format binary
> 
> Disassembly of section .data:
> 
> 00000000 <.data>:
>    0:	eaffffff 	b	0x4
>    4:	eb000000 	bl	0xc
>    8:	eafffffe 	b	0x8
>    c:	e92d4800 	push	{fp, lr}
> (...)
> ```



Of course, you can also use your favorite reverse engineering framework for disassembly and analysis, like *radare2* or *Ghidra* or ...



## What about the strange name of the tool?

The name **snowbirdopter** derives from the codename of the tiptoi pen's ARM processor[^1]  *snowbird* and the greek word *pteron* "wing". The snowbirdopter shall be used to let the snowbird's wings move so that it can fly[^2]! In addition, in the English language an *opter* is someone who opts, or makes a choice[^3] - e.g. to run own open-source software on the target.


[^0]: [tip-toi-reveng](https://github.com/entropia/tip-toi-reveng) github repository

[^1]: probably with an ARM926EJ-S core

[^2]: Have you ever heard about [ornithopters](https://en.wikipedia.org/wiki/Ornithopter)?

[^3]: [Wiktionary: opter](https://en.wiktionary.org/wiki/opter)

