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

http = require('http')
port = 1337

server = http.createServer((request, response) ->
  return )


server.listen(port, () ->
    console.log((new Date()) + " Server is listening on port " + port)
)

# Create new WebSocket server.
WebSocketServer = require('ws').Server
ws = new WebSocketServer({server: server})

# List of the peers connected to the server.
sockets = []

sockets.find = (id) ->
  for i in [0...sockets.length] by 1
    socket = sockets[i]
    if (id is socket.id)
      return socket

# On connection of a new peer.
ws.on('connection', (socket) ->
  console.log("Connection on WebSocket server used to connect peers")
  
  # On received message from a peer.
  socket.onmessage = (message) ->
    args = JSON.parse(message.data)

    eventName = args[0]
    socketId  = args[1]

    sock = sockets.find(socketId)
    if (sock)
      console.log(eventName)

      args[1] = socket.id

      sock.send(JSON.stringify(args), (error) ->
        if(error)
          console.log(error)
      )

  #On closed socket.
  socket.onclose = () ->
    console.log('close')

    sockets.splice(sockets.indexOf(socket), 1)

    for i in [0...sockets.length] by 1
        soc = sockets[i]

        console.log(soc.id)

        soc.send(JSON.stringify(["peer.remove", socket.id]),
        (error) ->
          if (error)
            console.log(error)
        )

  # Generate new ID.
  S4 = () ->
    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1)

  generateRandomId = () ->
    return (S4() + S4() + "-" + S4() + "-" + S4() + "-" +
            S4() + "-" + S4() + S4() + S4())

  socket.id = generateRandomId()
  
  console.log("new socket got id: " + socket.id)

  connectionsId = []

  for i in [0...sockets.length] by 1
    sock = sockets[i]
    
    connectionsId.push(sock.id)

    sock.send(JSON.stringify(["peer.create", socket.id]),
    (error) ->
      if (error)
        console.log(error))

  # Notify the new peer the list of the existing peers.
  socket.send(JSON.stringify(["peers", connectionsId]),
  (error) ->
    if(error)
      console.log(error)
  )

  # Add the new peer in peers list.
  sockets.push(socket)
)