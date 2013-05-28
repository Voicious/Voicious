###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class Notification extends Module
    constructor      : (NetworkManager) ->
        super NetworkManager
        @active = true

        do @checkFocus
        @enableNotification "newMessage"
        @enableNotification "newUser"

    # Checks if the user tab is active or not.
    checkFocus      : () =>
        $(window).blur () =>
             @active = false
        $(window).focus () =>
             @active = true

    # Enables a notification. Plays the corresponding notification if the user tab is not active.
    enableNotification      : (notifName) ->
        $(window).on notifName, () =>
             audio = document.getElementById notifName
             if !@active
                  do audio.play

if window?
     window.Notification = Notification