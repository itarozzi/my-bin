#! /bin/sh
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2013 Ivan Tarozzi
#----------------------------------------------------------------------
# author: Ivan Tarozzi <itarozzi@gmail.com>
#
# Description:
# dump sd content to image file 
# =============================================
#
# TODO: 
# - set sd device reading from discovered devices
# - assign destination path
# - suppress umount output
# - set -u doesn't works!
# =============================================


#=== bash options ===  
#-n  noexec -> read commands but not execute (check syntax)
#-u  nounset -> error if undefined variable exists
#-v verbose -> print commands to stdout
#-x xtrace -> same as -v, but expands commands
#set -u

#------------------------------------------------
# Check for superuser permission
#------------------------------------------------
if [ `id -u` -ne 0 ]; then
  echo "ERROR: please, execute this script as root!"
  exit 1
fi


SD_DEVICE="/dev/sdb"

#===  usage function ===
usage()
{
    echo "--------------------------------------------"
    echo "usage: ‘basename $0‘ [filename.img]"
    exit 1
}

#=== lockfile ===
me=$(basename $0)
lockfile=/tmp/${me}_running.lock

if [ -e $lockfile ]; then
    echo "ERROR: another process is running!"
    exit 1
fi

lockfile $lockfile 

#===  test arguments presence ===
if [ -z "$1" ]; then
  sdtype="";

  while [ "$sdtype" = "" ] 
  do
    echo "Select raspberry pi SD type:"
    echo "1) OpenELEC"
    echo "2) Raspbian"
    echo "3) Raspbmc"
    echo "4) generic-rpi"
    echo "q) quit"

    read sdtype
    case "$sdtype" in
       "1" ) sdtype="openelec";;
       "2" ) sdtype="raspbian";;
       "3" ) sdtype="raspbmc";;
       "4" ) sdtype="generic";;
       "q" ) rm -rf $lockfile; exit 1;;
       *   ) sdtype="";;
    esac
  done
  
  #=== Assign current date&time ===
  BACKUP_TIME=$(date +%Y%m%d%H%M)
  imgfilename="$sdtype-backup-$BACKUP_TIME.img"
 
else
  imgfilename=$1
fi

mounted=$( mount|grep "$SD_DEVICE" )
if [ -n "$mounted" ]; then
  echo "umount SD partitions"
  umount $SD_DEVICE1  
  umount $SD_DEVICE2 

fi

echo "dumping SD to $imgfilename......"  

dd if=$SD_DEVICE of=$imgfilename bs=1M

echo "compressing image......"  
if [ $? -eq 0 ]; then
  bzip2 $imgfilename
fi


if [ $? -eq 0 ]; then
  echo "Backup complete successfully!"  
fi
# -------------------- Exit & Unlock---------
rm -rf $lockfile 





