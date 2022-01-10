# README

The goal is to replace an ARM binary within a game (.gme) file.



# Steps

**CAUTION: PERFORM THE FOLLOWING STEPS AT YOUR OWN RISK!**

Execute the following sequence of Bash scripts:

## Required only once

1. Download original game file (e.g. using tttool's testsuite[^0]) and store a copy of it called `game.gme` to this directory
1. Modify the contents of `gme_name` to include the file name of the game file (e.g. `Spielfiguren2.gme`)
1. Analyze the game file;
   execute `./analyze_gme.sh` (it works with an input file called `game.gme`);
   it determines the offsets (as hex numbers) and sizes (as decimal numbers) of the embedded ARM binaries and stores this info as a table in `binaries.csv`
1. Extract the binary from the game file and disassemble it;
   execute `./extract_bin.sh` (it also works with the `game.gme` file);
   it will extract all "Header/Single binary <n>/Main" files as `game<n>.bin` and disassemble them to `game<n>.s`  (where n=1,2,3,...)
1. Inspect the game's assembly code in `game<n>.s`

## For every change made to the binary (WIP)

-- WIP -- this part needs to be updated
1. ***Modify `main.c`, `dumpregs.s` and `Makefile` according to your needs -
   i.e. to build your custom binaries which are going to replace the original ones (`game<n>.bin`)***
1. Build the new game by calling `make`;
   this will internally call `patch_gme.sh` after having built the code
   (it also uses dynamic address offsets and sizes as in `analyze_gme.sh`/`extract_bin.sh`)
1. Attach the tiptoi in USB mass storage mode and upload the new game file;
   either do it manually or by calling (the modified) `upload_gme.sh`
1. Re-power the tiptoi
1. Open your favorite serial terminal and connect to the USB/serial converter
1. Tip the tiptoi on your OID code and check the serial terminal for outputs

[^0]: [tip-toi-reveng](https://github.com/entropia/tip-toi-reveng/tree/master/testsuite) github repository
