# README

The goal is to dump the registers from within a game (.gme) file.



# Steps

**CAUTION: PERFORM THE FOLLOWING STEPS AT YOUR OWN RISK!**

1. Download original game file;
   modify and execute `download_gme.sh`
2. Analyze the game file;
   modify and execute `analyze_gme.sh`
3. Extract the binary from the game file and disassemble it;
   modify and execute `extract_bin.sh`
4. Inspect the game's assembly code in `game.s`
5. Modify `main.c`, `dumpregs.s` and `Makefile` according to your needs
6. Build the new game by calling `make`;
   this will internally call `patch_gme.sh`
7. Attach the tiptoi in USB mass storage mode and upload the new game file;
   either do it manually or by calling (the modified) `upload_gme.sh`
8. Re-power the tiptoi
9. Open your favorite serial terminal and connect to the USB/serial converter
10. Tip the tiptoi on your OID code and check the serial terminal for outputs