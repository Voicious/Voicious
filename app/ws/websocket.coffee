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
MD5     = require 'MD5'

Config  = require '../common/config'
{Db}    = require '../common/' + Config.Database.Connector

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
        try
            Db.get 'room', rid, (body) =>
                if Object.keys(body).length > 0
                    Db.get 'user', uid, (body) =>
                        if Object.keys(body).length > 0 and body.id_room is rid
                            @acceptSock body._id, rid, body.name, sock

    sendPing : (sock) =>
        sock._h       = MD5 do Date.now
        @send sock, { type : 'ping', params : { token : sock._h } }
        sock._timeout = setTimeout (() =>
            @pingTimeout sock
        ), 30000

    pingTimeout : (sock) =>
        @close sock, 'Ping timeout'

    acceptSock : (uid, rid, name, sock) =>
        that             = @
        sock.rid         = rid
        sock.uid         = uid
        sock.name        = name
        sock._h          = undefined
        sock._timeout    = undefined
        sock._nextPing   = undefined
        sock.onmessage   = (message) ->
            that.onmessage @, message
        sock.onclose     = () ->
            that.close @
        Db.get 'room', rid, (res) =>
            owner = if String res.owner is uid then true else false
            Db.get 'user', uid, (res) =>
                res.owner = owner
                @send sock, { type : 'authenticated', params : res }
                sock._nextPing   = setTimeout (() =>
                    @sendPing sock
                ), 60000
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

    close : (sock, reason = 'Session closed') =>
        if sock._timeout?
            clearTimeout sock._timeout
            sock._timeout  = undefined
        if sock._nextPing?
            clearTimeout sock._nextPing
            sock._nextPing = undefined
        delete @socks[sock.rid][sock.uid]
        for uid of @socks[sock.rid]
            if @socks[sock.rid][uid]?
                @send @socks[sock.rid][uid], { type : 'peer.remove' , params : {
                    id     : sock.uid
                    name   : sock.name
                    reason : reason
                } }

    onmessage : (sock, message) =>
        message = JSON.parse message.data
        switch message.type
            when 'forward' then do () =>
                # Temporary
                # check for the command system
                if message.params.data.type is 'user.kick'
                    Db.get 'room', sock.rid, (res) =>
                        owner = String res.owner
                        from = String sock.uid
                        if owner is from
                            s = @socks[sock.rid][message.params.to]
                            if s?
                                message.params.data.params.from = sock.uid
                                @send @socks[sock.rid][message.params.to], message.params.data
                        else
                            error = { type : 'chat.message',  params : {text : 'kick: forbidden.'} }
                            @send @socks[sock.rid][from], error
                else
                    s = @socks[sock.rid][message.params.to]
                    if s?
                        message.params.data.params.from = sock.uid
                        @send @socks[sock.rid][message.params.to], message.params.data

            when 'pong' then do () =>
                if message.params.token is sock._h
                    clearTimeout sock._timeout
                    sock._timeout  = undefined
                    sock._h        = undefined
                    sock._nextPing = setTimeout (() =>
                        @sendPing sock
                    ), 60000

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
