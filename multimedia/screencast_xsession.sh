#!/bin/bash
# - Script per Screencast Capture -
# http://wiki.linuxaudio.org/wiki/screencasttutorial

# Set up nested X server

#Xephyr suggerito nel tutorial va in crash quando lancio Xsession
# al momento lo sostituisco con Xnest
#Xephyr -keybd ephyr,,,xkbmodel=evdev -br -reset -host-cursor -screen 1280x720x24 -dpi 96 :2 &

Xephyr  -screen 1280x720x24 -dpi 96 :2 &

#Xnest -full -geometry 1280x720+0+0 -depth 24 -name screencast :3 &


sleep 3
export DISPLAY=:2.0

/etc/X11/Xsession &

