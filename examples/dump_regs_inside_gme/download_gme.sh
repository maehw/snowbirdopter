#!/usr/bin/env bash

gme_name=`cat gme_name`
echo "[INFO] gme_name='$gme_name'"

url=https://ssl-static.ravensburger.de/db/applications/$gme_name
echo "[INFO] url='$url'"

# Download original gme file
wget $url 

# Copy it so that the next scripts can work on the more generic file name 'game.gme';
# keep original file
cp $gme_name game.gme

