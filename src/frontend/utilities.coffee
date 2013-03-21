###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

# Contain useful functions.
class   Utilities
    constructor         : () ->

    # Generate a random number.
    randNb              : () =>
        return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

    # Generate a random key.
    generateRandomId    : () =>
        return (@randNb() + @randNb() + "-" + @randNb() + "-" + @randNb() +
                "-" + @randNb() + "-" + @randNb() + @randNb() + @randNb())

    # Split a string by size and return an array of strings.
    splitString         : (str, len) =>
        size    = Math.ceil str.length / len 
        ret     = []
        lc      = 0

        for i in [0...size] by 1
            ret[i] = str.slice lc, lc += len

        return ret

    # Get the size of a map.
    getMapSize          : (map) =>
        i = 0
        for key, val of map
            i++
        return i

U = Utilities

if window?
    window.Utilities    = new U
if exports?
    exports.Utilities   = new U