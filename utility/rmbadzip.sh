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
# Copyright 2011 Ivan Tarozzi
#----------------------------------------------------------------------

# Test zip files and remove if not readable
#
# author: Ivan Tarozzi <itarozzi@gmail.com>
# date: 28/01/2011

[ -z "$1" ] &&	echo "usage: $(basename $0) path"  && exit 1

for name in  $( find $1)
do
  [ ! -f $name ] && echo "skip $name" && continue
  
  echo processing $name
  zip -T $name 2&>/dev/null 
  [ $? -gt 0 ] && echo "Content error! => remove $name" && rm -f $name
  
done

