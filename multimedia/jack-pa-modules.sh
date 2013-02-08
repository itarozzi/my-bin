#! /bin/sh

# Load pulseaudio modules to route PA over jack
# This script should be executed after jackd starts
# You can use qjackctl GUI to execute it

sleep 3

pactl load-module module-jack-sink channels=2; 
pactl load-module module-jack-source channels=2;
pacmd set-default-sink jack_out

