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

class Ws
    constructor : (@uid, @rid, ws) ->
        @ws           = new WebSocket "ws://#{ws.host}:#{ws.port}"
        @ws.onopen    = @onOpen
        @ws.onmessage = @onMessage

    send : (data) =>
        @ws.send JSON.stringify data

    onOpen : () =>
        auth =
            type   : 'authenticate'
            params :
                rid : @rid
                uid : @uid
        @send auth

    onMessage : (message) =>
        console.log message

class Connections
    constructor : (uid, rid, ws) ->
        @ws = new Ws(uid, rid, ws)

if window?
    if not window.Voicious?
        window.Voicious = { }
    window.Voicious.Connections = Connections
