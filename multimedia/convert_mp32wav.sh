#! /bin/bash

##############################################################################
# Convert and !delete! all mp3 files under the directory passed as arguments
# to wav file.
#
# require mpg123
#
# I used this to convert scratch 1.4 media files because mp3 files are not
# working in my Linux machine:
# sudo ./convert_mp32wav.sh /usr/share/scratch/Media/Sounds
#
#
# Author: Ivan Tarozzi (itarozzi@gmail.com)
# 08/02/2017
#
##############################################################################
WORKINGPATH=$1

find $WORKINGPATH -name '*.mp3' -print | while read filename; do
  echo $filename
  mpg123 -w "${filename%.*}.wav" "$filename";
  rm "$filename";
done
