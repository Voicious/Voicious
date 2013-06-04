###

Copyright (c) 2011-2013  Voicious

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

Config  = require '../common/config'
{Db}    = require '../core/' + Config.Database.Connector

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
        Db.get 'room', rid, (body) =>
            if Object.keys(body).length > 0
                Db.get 'user', uid, (body) =>
                    if Object.keys(body).length > 0 and body.id_room is rid
                        @acceptSock body._id, rid, body.name, sock

    acceptSock : (uid, rid, name, sock) =>
        that             = @
        sock.rid         = rid
        sock.uid         = uid
        sock.name        = name
        sock.onmessage   = (message) ->
            that.onmessage @, message
        sock.onclose     = () ->
            that.close @
        @send sock, { type : 'authenticated' }
        if not @socks[rid]?
            @socks[rid] = { }
        else
            peers = []
            for _uid of @socks[rid]
                if @socks[rid][_uid]?
                    @send @socks[rid][_uid], { type : 'peer.create' , params : { id : uid , name : name } }
                    if _uid isnt uid
                        peers.push { id : _uid , name : @socks[rid][_uid].name }
            @send sock, { type : 'peer.list' , params : { peers : peers } }
        @socks[rid][uid] = sock

    close : (sock) =>
        delete @socks[sock.rid][sock.uid]
        for uid of @socks[sock.rid]
            if @socks[sock.rid][uid]?
                @send @socks[sock.rid][uid], { type : 'peer.remove' , params : { id : sock.uid , name : sock.name  } }

    onmessage : (sock, message) =>
        message = JSON.parse message.data
        switch message.type
            when 'forward' then do () =>
                s = @socks[sock.rid][message.params.to]
                if s?
                    message.params.data.params.from = sock.uid
                    @send @socks[sock.rid][message.params.to], message.params.data

    send : (sock, message) =>
        if sock.readyState is 1
            sock.send JSON.stringify message

    start : () =>
        Db.connect () =>
            @server = new Ws {
                server : (Http.createServer (req, res) ->).listen Config.Websocket.Port, () =>
                    console.log "Server ready on port #{Config.Websocket.Port}"
                }
            @server.on 'connection', @onConnection

do (new Websocket).start
