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

# The event manager contain callbacks array
class   EventManager
    constructor         : () ->
        @events = {}
        
    # Get a callback from the array with a string
    getEvent            : (eventName) =>
        for key, val of @events
            if eventName == key
                return val
        return null
        
    # Add a new callback into the array with a string as a key
    addEvent            : (eventName, event) =>
        @events[eventName] = event

EM = new EventManager

if window?
    window.EventManager     = EM
if exports?
    exports.EventManager    = EM