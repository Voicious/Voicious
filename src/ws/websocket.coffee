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

Request     = require 'request'
Config      = require '../common/config'
{Errors}    = require '../core/errors'

webSocketServer = require('websocket').server
http            = require('http')

# Create basic http server.
server = http.createServer((request, response) ->
  console.log((new Date()) + ' Received request for ' + request.url)
  response.writeHead(404)
  response.end()
)

server.listen Config.Websocket.Port, () ->
    console.log "Server ready on port " + Config.Websocket.Port

# Create WebSocket server.
wsServer = new webSocketServer {httpServer: server}

# List of the peers connected to the server.
sockets = []
rooms   = {}

# Generate new ID.
S4 = () ->
  return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

generateRandomId = () ->
  return (S4() + S4() + "-" + S4() + "-" + S4() + "-" +
          S4() + "-" + S4() + S4() + S4())

# Notify the error and close the socket.
errorCallback = (param, error) ->
    console.log error
    Errors.Error error
    param.socket.close

# Delete token from database
deleteToken = (token) ->
  Request.del "#{Config.Restapi.Url}/token/#{token}", (e, r, data) =>
    if e? or r.statusCode > 200
      Errors.Error error "Failed to delete token"
    else
      console.log "Token has been deleted"

# Authentification functions.
clientValidation = (param) ->
  Request.get "#{Config.Restapi.Url}/user/#{param.idClient}", (e, r, data) =>
    if e? or r.statusCode > 200
      param.errorCallback param, "Invalid client id"
    else
      data = JSON.parse(data)
      # if param.idRoom == data.id_room
      acceptPeer param
      

roomValidation = (param) ->
  Request.get "#{Config.Restapi.Url}/room/#{param.idRoom}", (e, r, data) =>
    if e? or r.statusCode > 200
      param.errorCallback param, "Invalid room id"
    else
      clientValidation param

tokenValidation = (param) ->
  infos = {}
  Request.get "#{Config.Restapi.Url}/token/#{param.token}", (e, r, data) =>
    if e? or r.statusCode > 200
      param.errorCallback param, "Invalid token"
    else
      deleteToken param.token
      data = JSON.parse(data)
      if param.idRoom == data.id_room
        param.idClient = data.id_user
        roomValidation param
      else
        param.errorCallback param, "Invalid room id"

#Enable peer on the server.
acceptPeer = (param) ->
  idClient        = generateRandomId()
  socket          = param.socket
  socket.idRoom   = param.idRoom
  socket.idClient = idClient
  socket.enable   = true

  if not rooms[param.idRoom]
    roomSockets                   = {}
    roomSockets[idClient]         = socket
    rooms[param.idRoom]           = roomSockets
  else
    rooms[param.idRoom][idClient] = socket
  console.log "Peer accepted"
  console.log rooms

# On a new connection.
wsServer.on('request', (request) ->
  
  console.log "New client has arrived from : " + request.origin

  socket = request.accept null, request.origin
  
  socket.idClient = -1
  socket.idRoom   = -1
  socket.enable   = false
  
  sockets.push(socket)
  
  # On received message from a peer.
  socket.on('message', (message) ->
    if message.type == 'utf8'
      args = JSON.parse message.utf8Data

      eventName = args[0]
      idRoom    = args[1]
      
      console.log eventName
      if socket.enable
        console.log eventName
#        clientToSendId = args[2]
#
#        console.log(eventName)
#        sock = room[idRoom][clientToSendId]
#        if sock?
#          args[2] = socket.idClient
#
#          sock.sendUTF JSON.stringify(args), (error) ->
#            if error
#              console.log error
      else
        if eventName == 'authentification'
#          console.log "Authentification"
          token     = args[2]
          
          param   =
              socket          : socket
              token           : token
              idRoom          : idRoom
              errorCallback   : errorCallback
          
          tokenValidation(param)
        else
          console.log "authentification failed"
          socket.close
    )

  #On closed socket.
  socket.on('close', () ->
    if socket.enable == true
      if socket.idRoom != -1 && rooms[socket.idRoom]
        rooms[socket.idRoom][socket.idClient] = null
    sockets.splice sockets.indexOf(socket), 1
    console.log('close')
    )

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
)