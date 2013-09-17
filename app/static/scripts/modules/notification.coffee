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
    constructor      : (emitter) ->
        super emitter
        @active = true

        @jqAudio = $ "audio#notification"
        @jqAudio.on 'ended', (e) =>
            @active = true

        do @checkFocus
        @enableNotification "chat.message"
        @enableNotification "peer.create"

    # Checks if the user tab is active or not.
    checkFocus      : () =>
        $(window).blur () =>
            @active = true
        $(window).focus () =>
            @active = false

    # Enables a notification. Plays the corresponding notification if the user tab is not active.
    enableNotification      : (notifName) ->
        @emitter.on notifName, () =>
             if @active is on
                @jqAudio.attr 'src', '/sounds/notification/' + notifName + '.mp3'
                do @jqAudio[0].play
                @active = false

if window?
     window.Notification = Notification