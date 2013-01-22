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
    constructor       : () ->
        @networkManager = NetworkManager 'localhost', 1337

    joinConference    : () =>
        options =
            video       : localVideo
            onsuccess   : (stream) =>
                trace "Success to load video."
                window.localStream   = stream
                @joinConference.disabled = true
                @networkManager.negociatePeersOffer stream
            onerror     : (e) =>
                trace "Video or audio are not available#{e}."

        Media(options)

    start             : () =>
        do @networkManager.connection
        $('#joinConference').click () =>
           @joinConference()

room              = new Room

$(document).ready ->
    localVideo  = 'localVideo'
    do room.start

if window?
    window.trace     = trace
if exports?
    exports.trace    = trace