#! /bin/bash

##############################################################################
# Convert and !delete! all jpg files under the directory passed as arguments
# to png file.
#
# require imagemagick
#
# I used this to convert scratch 1.4 media files because jpeg files are not
# working in my Linux machine:
# sudo ./convert_jpg2png.sh /usr/share/scratch/Media
#
# ln -s Scrivania Desktop
# ln -s Documenti Documents
#
#
# Author: Ivan Tarozzi (itarozzi@gmail.com)
# 08/02/2017
#
##############################################################################
WORKINGPATH=$1

find $WORKINGPATH -name '*.jpg' -print | while read filename; do
  echo $filename
  convert "$filename" "${filename%.*}.png" ;
  rm "$filename";
done
