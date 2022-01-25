# README

The goal is to replace an ARM binary within a game (.gme) file.



# Steps

**CAUTION: PERFORM THE FOLLOWING STEPS AT YOUR OWN RISK!**

Execute the following sequence of Bash scripts:

## Required only once

1. Download original game file (e.g. using tttool's testsuite[^0]) and store a copy of it called `game.gme` to this directory
1. Analyze the game file;
   execute `./analyze_gme.sh game.gme`;
   it determines the offsets (as hex numbers) and sizes (as decimal numbers) of the embedded ARM binaries and stores this info as a table in `binaries.csv`
1. Extract the binaries from the game file (and disassemble them);
   execute `./extract_bin.sh game.gme` (using the `binaries.csv` file from the previous step);
   it will extract all "Header/Single binary <n>/Main" files as `game<n>.bin` and also directly disassemble them to `game<n>.s`  (where n=1,2,3,...)
1. If wanted, inspect the game's assembly code in `game<n>.s`

## For every change made to the binary/binaries

1. Modify `main.c`, `dumpregs.s` and `Makefile` according to your needs -
   i.e. to build your custom binaries which are going to replace the original ones (`game<n>.bin`)
1. Build your own code by calling `make`
1. Replace one or all of your game binaries (`game<n>.bin`) with `out.bin`
1. Call `patch_gme.sh` to created a patched game file
   (it also uses dynamic address offsets and sizes as in `analyze_gme.sh`/`extract_bin.sh` from `binaries.csv`)
1. Attach the tiptoi in USB mass storage mode and upload the new game file;
   either do it manually or by calling (the modified) `upload_gme.sh`
1. Re-power the tiptoi
1. Open your favorite serial terminal and connect to the USB/serial converter
1. Tip the tiptoi on your OID code and check the serial terminal for outputs

[^0]: [tip-toi-reveng](https://github.com/entropia/tip-toi-reveng/tree/master/testsuite) github repository
