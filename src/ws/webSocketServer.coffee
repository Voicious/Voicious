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

server.listen(Config.WSServer.Port, () ->
    console.log((new Date()) + " Server is listening on port " + Config.WSServer.Port)
)

# Create WebSocket server.
wsServer = new webSocketServer({httpServer: server})

# List of the peers connected to the server.
sockets = []
rooms   = {}

roomValidation = (roomId) ->
  Request.get "#{Config.Restapi.Url}/room/#{roomId}", (e, r, datas) =>
    if e
        Errors.error(e[0])
        return false
    else
        return true

getClientDatas = (clientId) ->
  Request.get "#{Config.Restapi.Url}/user/#{clientId}", (e, r, datas) =>
    if e
        Errors.error(e[0])
        return null
    else
      datas = JSON.parse(datas)
      return datas

# On connection of a new peer.
wsServer.on('request', (request) ->
  
  console.log "New client has arrived from : " + request.origin

  socket = request.accept(null, request.origin)
  
  socket.clientId = -1
  socket.roomId   = -1
  socket.enable   = false
  
  sockets.push(socket)
  
  # On received message from a peer.
  socket.on('message', (message) ->
    if message.type == 'utf8'
      args = JSON.parse(message.utf8Data)

      eventName = args[0]
      roomId    = args[1]

      if (socket.enable and rooms[roomId])
        clientToSendId  = args[2]

        console.log(eventName)
        sock = room[roomId][clientToSendId]
        if sock?
          args[1] = socket.clientId

          sock.sendUTF(JSON.stringify(args), (error) ->
            if(error)
              console.log(error))
      else
        if eventName == 'authentification'
          console.log "Authentification"

          clientId  = args[2]
          
          if roomValidation?
            console.log "Room" + roomId + " is valid"
            datas = getClientDatas(clientId)
            if datas?
              socket.roomId   = roomId
              socket.clientId = clientId
              socket.enable         = true

              if not rooms[roomId]
                roomSockets             = {}
                roomSockets[clientId]   = socket
                rooms[roomId]           = roomSockets
              else
                rooms[roomId][clientId] = socket
                
              console.log rooms
            else
              socket.close()
          else
            socket.close()
        else
          socket.close()
    )

  #On closed socket.
  socket.on('close', () ->
    if socket.enable == true
      if socket.roomId != -1 && rooms[socket.roomId]
        rooms[socket.roomId][socket.clientId] = null
    sockets.splice(sockets.indexOf(socket), 1)
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