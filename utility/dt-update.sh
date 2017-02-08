#! /bin/bash 
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

# Update darktable installation from git (master)
#
# author: Ivan Tarozzi <itarozzi@gmail.com>
# date: 28/01/2013

set -u


#------------------------------------------------
#  Ask for sudo password, to use sudo below
#------------------------------------------------
sudo echo "" > /dev/null

if [ $? -ne 0 ]; then
  echo "invalid sudo password!"
  exit 1
fi


cd ~/src/darktable &&\
git pull && \
cd build && \
make && sudo make install




