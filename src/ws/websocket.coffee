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
WebSocketServer   = require('websocket').server
Http              = require('http')
Config            = require '../common/config'
{Errors}          = require '../core/errors'
{Token}           = require '../core/token'

randNb            = () ->
  return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

generateRandomId  = () ->
  return (randNb() + randNb() + "-" + randNb() + "-" + randNb() + "-" +
          randNb() + "-" + randNb() + randNb() + randNb())

class Websocket
        constructor       : () ->
            @sockets    = []
            @rooms      = {}
            @token      = Token

        errorCallback     : (param, error) ->
            console.log error
            Errors.Error error
            param.socket.close

        notifyNewPeer     : (socket) ->
            peersId   = []
            sockets   = @rooms[socket.idRoom]
            
            for key, val of sockets
                sock  = val
                peersId.push sock.idClient
                @socketOnSend sock, ["peer.create", socket.idClient]

            @socketOnSend socket, ["peers", peersId]

        acceptPeer        : (param) ->
            idClient        = generateRandomId()
            socket          = param.socket
            socket.idRoom   = param.idRoom
            socket.idClient = idClient
            socket.enable   = true

            @notifyNewPeer socket

            if not @rooms[param.idRoom]
              roomSockets                   = {}
              roomSockets[idClient]         = socket
              @rooms[param.idRoom]           = roomSockets
            else
              @rooms[param.idRoom][idClient] = socket

        clientValidation  : (param) ->
            that = this
            Request.get "#{Config.Restapi.Url}/user/#{param.idClient}", (e, r, data) =>
              if e? or r.statusCode > 200
                param.errorCallback param, "Invalid client id"
              else
                data = JSON.parse(data)
                # if param.idRoom == data.id_room
                that.acceptPeer param


        roomValidation    : (param) ->
            that = this
            Request.get "#{Config.Restapi.Url}/room/#{param.idRoom}", (e, r, data) =>
              if e? or r.statusCode > 200
                  param.errorCallback param, "Invalid room id"
              else
                  that.clientValidation param

        tokenValidation   : (param) ->
            that = this
            Request.get "#{Config.Restapi.Url}/token/#{param.token}", (e, r, data) =>
              if e? or r.statusCode > 200
                  param.errorCallback param, "Invalid token"
              else
                  @token.deleteToken param.token
                  data = JSON.parse(data)
                  if param.idRoom == data.id_room
                    param.idClient = data.id_user
                    that.roomValidation param
                  else
                    param.errorCallback param, "Invalid room id"

        peerRemove        : (socket) ->
            sockets   = @rooms[socket.idRoom]

            for key, val of sockets
                sock = val

                console.log(sock.idClient)
                @socketOnSend sock, ["peer.remove", socket.idClient]

        socketOnSend      : (socket, msg) ->
            msg = JSON.stringify(msg)
            console.log "Send : #{msg}"

            socket.send msg, (error) ->
                if (error)
                    console.log(error)

        socketOnMessage   : (socket, message) ->
            if message.type == 'utf8'
                args = JSON.parse message.utf8Data
            else if message.type == 'binary'
                return

            event = args[0]

            if socket.enable
                sock          = @room[socket.idRoom][args[1]]

                if sock?
                    args[1]   = socket.idClient
                    @onSocketSend sock, args

            else if event? and event == 'authentification'
                idRoom    = args[1]
                param     =
                    socket          : socket
                    token           : args[2]
                    idRoom          : idRoom
                    errorCallback   : @errorCallback

                @tokenValidation(param)

        socketOnClose     : (socket) ->
            if socket.enable == true
                delete @rooms[socket.idRoom][socket.idClient]
                @peerRemove socket
            @sockets.splice @sockets.indexOf(socket), 1
            console.log 'close'

        serverOnRequest   : (request) ->
            console.log "New client has arrived from : " + request.origin

            that            = this
            socket          = request.accept null, request.origin

            socket.idClient = -1
            socket.idRoom   = -1
            socket.enable   = false

            socket.on 'message', (message) ->
                that.socketOnMessage socket, message
            socket.on 'close', () ->
                that.socketOnClose socket

            @sockets.push socket

        start       : () ->
            that       = this
            server     = Http.createServer((req, res) ->).listen Config.Websocket.Port, () ->
                console.log "Server ready on port #{Config.Websocket.Port}"
            @wsServer   = new WebSocketServer {httpServer: server}
            @wsServer.on 'request', (request) ->
                that.serverOnRequest request

websocket = new Websocket
do websocket.start

#    sockets.splice(sockets.indexOf(socket), 1)
#
#    for i in [0...sockets.length] by 1
#        soc = sockets[i]
#
#        console.log(soc.id)
#
#        soc.send(JSON.stringify(["peer.remove", socket.id]),
#        (error) ->
#          if (error)
#            console.log(error)
#        )
#
#  connectionsId = []
#
#  for i in [0...sockets.length] by 1
#    sock = sockets[i]
#
#    connectionsId.push(sock.id)
#
#    sock.send(JSON.stringify(["peer.create", socket.id]),
#    (error) ->
#      if (error)
#        console.log(error))

#  # Notify the new peer the list of the existing peers.
#  socket.send(JSON.stringify(["peers", connectionsId]),
#  (error) ->
#    if(error)
#      console.log(error)
#  )