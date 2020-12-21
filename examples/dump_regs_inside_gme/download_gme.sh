#!/usr/bin/env bash

# Download original 'Spielfiguren2.gme'
wget https://ssl-static.ravensburger.de/db/applications/Spielfiguren2.gme

# Copy it so that the next scripts can work on the more generic file name 'game.gme';
# keep original file
cp Spielfiguren2.gme game.gme

