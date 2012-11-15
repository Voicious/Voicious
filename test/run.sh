###
#
# Copyright (c) 2011-2012  Voicious
#
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU Affero General Public License as published by the Free Software Foundation, either version
# 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with this
# program. If not, see <http://www.gnu.org/licenses/>.
#
###

#!/bin/sh

VOWS=./node_modules/vows/bin/vows
CAKE=cake

VOWSARGS="--spec"

$CAKE build

if [ $# -gt 0 ]
then
  for suite in $*
  do
    if [ -f "./$suite" ]
    then
      $VOWS $VOWSARGS "./$suite"
    elif [ -f "./${suite}.js" ]
    then
      $VOWS $VOWSARGS "./${suite}.js"
    fi
  done
else
    $VOWS $VOWSARGS *.js
fi
