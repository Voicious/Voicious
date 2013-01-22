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

Request           = require 'request'
WebSocketServer   = require('ws').Server
Http              = require('http')
Config            = require '../common/config'
{Errors}          = require '../core/errors'
{Token}           = require '../core/token'

# Generate random ID
randNb            = () ->
  return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

generateRandomId  = () ->
  return (randNb() + randNb() + "-" + randNb() + "-" + randNb() + "-" +
          randNb() + "-" + randNb() + randNb() + randNb())

# Variables tips:
#
# rid   -> roomID
# cid   -> clientID
# cinfo -> clientInfo

# WebSocket server
class Websocket
        constructor       : () ->
            @sockets    = []
            @rooms      = {}
            @token      = Token

        notifyNewPeer     : (socket) =>
            clientsInfos    = []
            sockets         = @rooms[socket.rid]
            
            for key, val of sockets
                sock = val
                clientsInfos.push sock.cinfo
                @socketOnSend sock, ["peer.create", socket.cinfo]

            @socketOnSend socket, ["peers", clientsInfos]

        acceptPeer        : (param) =>
            cid               = generateRandomId()
            socket            = param.socket
            socket.rid        = param.rid
            socket.cinfo      = param.cinfo
            socket.enable     = true

            socket.cinfo.cid  = cid

            @notifyNewPeer socket

            if not @rooms[param.rid]
              roomSockets                   = {}
              roomSockets[cid]              = socket
              @rooms[param.rid]             = roomSockets
            else
              @rooms[param.rid][cid]        = socket

        clientValidation  : (param) =>
            Request.get "#{Config.Restapi.Url}/user/#{param.cid}", (e, r, data) =>
              if e? or r.statusCode > 200
                param.errorCallback param, "Invalid client id"
              else
                data = JSON.parse(data)
                # if param.rid == data.id_room # check client id room to avoid multiple same client
                client =
                    name  : data.name
                    
                param.cinfo  = client
                @acceptPeer param


        roomValidation    : (param) =>
            Request.get "#{Config.Restapi.Url}/room/#{param.rid}", (e, r, data) =>
              if e? or r.statusCode > 200
                  param.errorCallback param, "Invalid room id"
              else
                  @clientValidation param

        tokenValidation   : (param) =>
            Request.get "#{Config.Restapi.Url}/token/#{param.token}", (e, r, data) =>
              if e? or r.statusCode > 200
                  param.errorCallback param, "Invalid token"
              else
                  @token.deleteToken param.token
                  data = JSON.parse(data)
                  if param.rid == data.id_room
                    param.cid = data.id_client
                    @roomValidation param
                  else
                    param.errorCallback param, "Invalid room id"

        peerRemove        : (socket) =>
            sockets  = @rooms[socket.rid]

            for key, val of sockets
                sock = val

                console.log(sock.cinfo.cid)
                @socketOnSend sock, ["peer.remove", socket.cinfo]

        socketOnSend      : (socket, msg) =>
            msg = JSON.stringify(msg)
            console.log "Send : #{msg}"

            socket.send msg, (error) ->
                if (error)
                    console.log(error)

        socketOnMessage   : (socket, message) =>
            if not message.data
                return
            args = JSON.parse message.data
            
            console.log "Received : #{args}"
            
            event = args[0]

            if socket.enable
                cinfo = args[1]
                if @rooms? and @rooms[socket.rid]? and cinfo?
                    sock = @rooms[socket.rid][cinfo.cid]

                    if sock?
                        args[1] = socket.cinfo
                        @socketOnSend sock, args

            else if event? and event == 'authentification'
                rid    = args[1]
                param  =
                    socket          : socket
                    token           : args[2]
                    rid             : rid
                    errorCallback   : () =>
                        console.log error
                        Errors.Error error
                        param.socket.close

                @tokenValidation(param)

        socketOnClose     : (socket) =>
            if socket.enable == true and @rooms[socket.rid]?
                delete @rooms[socket.rid][socket.cinfo.cid]
                @peerRemove socket
            @sockets.splice @sockets.indexOf(socket), 1
            console.log 'Socket closed'

        serverOnConnection   : (socket) =>
            console.log 'New client has arrived'

            socket.cid      = -1
            socket.rid      = -1
            socket.enable   = false

            socket.onmessage = (message) =>
                @socketOnMessage socket, message
            socket.onclose = () =>
                @socketOnClose socket

            @sockets.push socket

        start       : () =>
            server      = Http.createServer((req, res) ->).listen Config.Websocket.Port, () =>
                console.log "Server ready on port #{Config.Websocket.Port}"
            @wsServer   = new WebSocketServer {server: server}
            @wsServer.on 'connection', (socket) =>
                @serverOnConnection socket

websocket = new Websocket
do websocket.start