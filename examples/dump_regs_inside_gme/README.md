# README

The goal is to dump the registers from within a game (.gme) file.



# Steps

**CAUTION: PERFORM THE FOLLOWING STEPS AT YOUR OWN RISK!**

Execute the following sequence of Bash scripts:

1. Modify the contents of `gme_name` to include the file name of the game file (e.g. `Spielfiguren2.gme`)
2. Download original game file by calling `download_gme.sh` 
   a copy of the file will be stored in `game.gme`
3. Analyze the game file;
   execute `analyze_gme.sh` (it works with an input file called `game.gme`)
4. Extract the binary from the game file and disassemble it;
   execute `extract_bin.sh` (it also works with the `game.gme` file);
   it will extract all "Header/Single binary <n>/Main" files as `game<n>.bin` and disassemble them to  `game<n>.s`
5. Inspect the game's assembly code in `game<n>.s` (where n=1,2,3,...)

1. ***Modify `main.c`, `dumpregs.s` and `Makefile` according to your needs -
   i.e. to build your custom binaries which are going to replace the original ones (`game<n>.bin`)***
2. Build the new game by calling `make`;
   this will internally call `patch_gme.sh` after having built the code
   (it also uses dynamic address offsets and sizes as in `analyze_gme.sh`/`extract_bin.sh`)
3. Attach the tiptoi in USB mass storage mode and upload the new game file;
   either do it manually or by calling (the modified) `upload_gme.sh`
4. Re-power the tiptoi
5. Open your favorite serial terminal and connect to the USB/serial converter
6. Tip the tiptoi on your OID code and check the serial terminal for outputs