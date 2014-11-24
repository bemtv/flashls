#!/bin/bash
FLEXPATH=~/airsdk/

OPT_DEBUG="
    -use-network=false \
    -optimize=true \
    -compress=true \
    -strict=true \
    -use-gpu=true \
    -define=CONFIG::LOGGING,true \
    -define=CONFIG::FLASH_11_1,true"

OPT_RELEASE="
    -use-network=false \
    -optimize=true \
    -define=CONFIG::LOGGING,false \
    -define=CONFIG::FLASH_11_1,true"

echo "Compiling bin/release/HLSPlayer.swf"
$FLEXPATH/bin/mxmlc ../src/com/globo/Player.as \
    -source-path ../src \
    -o ../bin/release/HLSPlayer.swf \
    $OPT_RELEASE \
    -library-path+=../lib/blooddy_crypto.swc \
    -target-player="14.0" \
    -default-size 480 270 \
    -default-background-color=0x000000 \
    -default-frame-rate=60
./add-opt-in.py ../bin/release/HLSPlayer.swf

echo "Compiling bin/debug/HLSPlayer.swf"
$FLEXPATH/bin/mxmlc ../src/com/globo/Player.as \
    -source-path ../src \
    -o ../bin/debug/HLSPlayer.swf \
    $OPT_DEBUG \
    -library-path+=../lib/blooddy_crypto.swc \
    -target-player="14.0" \
    -default-size 480 270 \
    -default-background-color=0x000000 \
    -default-frame-rate=60
./add-opt-in.py ../bin/debug/HLSPlayer.swf


