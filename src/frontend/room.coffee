###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

trace = (text) ->
    console.log "#{text}"

class Room
    constructor         : () ->
        @userList       = new UserList
        @networkManager = NetworkManager '192.168.52.140', 1337
        do @configureEvents

    configureEvents     : () =>
        EventManager.addEvent "fillUsersList", (users) =>
            @userList.fill users
        EventManager.addEvent "updateUserList", (user, event) =>
            @userList.update user, event

    joinConference      : () =>
        options =
            video       : '#localVideo'
            onsuccess   : (stream) =>
                window.localStream          = stream
                @networkManager.negociatePeersOffer stream
                $('#joinConference').attr "disabled", "disabled"
            onerror     : (e) =>
                trace "Video or audio are not available#{e}."

        WebRTC.getUserMedia(options)

    start               : () =>
        do @networkManager.connection
        $('#joinConference').click () =>
            @joinConference()

$(window).load ->

$(document).ready ->
    if WebRTC.runnable?
        room = new Room
        do room.start
    else
        alert "To use Voicious you need to use the latest Chrome version"

if window?
    window.trace     = trace
if exports?
    exports.trace    = trace
