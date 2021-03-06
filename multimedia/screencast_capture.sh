#!/bin/bash

DATE=`date +%Y%m%d`
TIME=`date +%Hh%M`
export DISPLAY=:2.0

# Start screencast
xterm -display :0.0 -e jack_capture -b 24 $HOME/Screencasts/screencast_audio_$DATE-$TIME.wav &
ffmpeg -an -f x11grab -r 30 -s 1280x720 -i :2 -vcodec libx264 -vpre lossless_ultrafast -threads 4 $HOME/Screencasts/screencast_video_$DATE-$TIME.mkv

killall jack_capture

