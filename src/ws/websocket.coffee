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

Http    = require 'http'
Ws      = (require 'ws').Server
Request = require 'request'

Config = require '../common/config'

class Websocket
    constructor : () ->
        @socks = { }

    onConnection : (sock) =>
        that = @
        sock.onmessage = (message) ->
            message = JSON.parse message.data
            if message.type is 'authenticate'
                that.validateSock message.params.uid, message.params.rid, @

    validateSock : (uid, rid, sock) =>
        Request.get "#{Config.Restapi.Url}/room/#{rid}", (e, r, body) =>
            if not e?
                Request.get "#{Config.Restapi.Url}/user/#{uid}", (e, r, body) =>
                    body = JSON.parse body
                    if not e? and body.id_room is rid
                        @acceptSock uid, rid, sock

    acceptSock : (uid, rid, sock) =>
        sock.onmessage   = @onmessage
        @send sock, { type : 'authenticated' }
        if not @socks[rid]?
            @socks[rid] = { }
        else
            peers = []
            for uid of @socks[rid]
                peers.push uid
            @send sock, { type : 'peers' , params : { 'peers' : peers } }
        @socks[rid][uid] = sock

    onmessage : () =>

    send : (sock, message) =>
        sock.send JSON.stringify message

    start : () =>
        @server = new Ws {
            server : (Http.createServer (req, res) ->).listen Config.Websocket.Port, () =>
                console.log "Server ready on port #{Config.Websocket.Port}"
        }
        @server.on 'connection', @onConnection

do (new Websocket).start
