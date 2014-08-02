#!/bin/bash
FLEXPATH=~/airsdk/

OPT_DEBUG="-use-network=false \
    -optimize=true \
    -compress=true \
    -strict=true \
    -use-gpu=true \
    -define=CONFIG::LOGGING,true"

OPT_RELEASE="-use-network=false \
    -optimize=true \
    -compress=true \
    -strict=true \
    -use-gpu=true \
    -define=CONFIG::LOGGING,false"

echo "Compiling bin/debug/P2PHLSPlayer.swf"
$FLEXPATH/bin/mxmlc ../src/tv/bem/BemTVPlayer.as \
    -source-path ../src \
    -o /Users/flavio.barbosa/Development/bemtv/clappr-p2phls-plugin/public/P2PHLSPlayer.swf \
    $OPT_RELEASE \
    -library-path+=../lib/blooddy_crypto.swc \
    -target-player="11.5" \
    -default-size 480 270 \
    -default-background-color=0x000000 \
    -default-frame-rate=60
./add-opt-in.py /Users/flavio.barbosa/Development/bemtv/clappr-p2phls-plugin/public/P2PHLSPlayer.swf


