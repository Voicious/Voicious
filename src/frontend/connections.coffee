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
        @actions      = { }

    defineAction : (actionName, callback) =>
        @actions[actionName] = callback

    send : (data) =>
        @ws.send JSON.stringify data

    forward : (to, data) =>
        @send { type : 'forward' , params : { to : to , data : data } }

    onOpen : () =>
        auth =
            type   : 'authenticate'
            params :
                rid : @rid
                uid : @uid
        @send auth

    onMessage : (message) =>
        console.log message
        message = JSON.parse message.data
        if @actions[message.type]?
            @actions[message.type] message.params

class PC
    constructor : (@ws) ->
        iceServers   = { iceServers : [ { url : 'stun:23.21.150.121' } ] }
        @constraints =
            mandatory :
                OfferToReceiveAudio : yes
                OfferToReceiveVideo : yes
        @channels    = { }

        @pc          = new window.RTCPeerConnection iceServers
        @pc.onopen   = () =>

    createDataChannel : (name) =>
        @channels              = @pc.createDataChannel name, { }

        @channels[name].onopen = () =>
            console.log "OPENED"

    createOffer : (id) =>
        @pc.createOffer (description) =>
            @pc.setLocalDescription description, () =>
                @ws.forward id, { type : 'pc.offer' , params : { description : description } }
            , (error) =>
                return
        , (error) =>
            return
        , @constraints

    createAnswer : (id, offeredDescription) =>
        @pc.setRemoteDescription offeredDescription, () =>
            @pc.createAnswer (description) =>
                @pc.setLocalDescription description, () =>
                    @ws.forward id, { type : 'pc.answer', params : { description : description } }
                , (error) =>
                    return
            , (error) =>
                return
        , (error) =>
            return

    conclude : (answeredDescription) =>
        @pc.setRemoteDescription answeredDescription

class Peer
    constructor : (ws, @id, @name) ->
        @pc = new PC ws

    offerHandshake : () =>
        @pc.createOffer @id

    answerHandshake : (offeredDescription) =>
        @pc.createAnswer @id, (new window.RTCSessionDescription offeredDescription)

    concludeHandshake : (answeredDescription) =>
        @pc.conclude (new window.RTCSessionDescription answeredDescription)

class Connections
    constructor : (uid, rid, ws) ->
        @peers = { }
        @ws    = new Ws(uid, rid, ws)
        @ws.defineAction 'peer.list', (data) =>
            for peer in data.peers
                @peers[peer.id] = new Peer @ws, peer.id, peer.name
                do @peers[peer.id].offerHandshake
        @ws.defineAction 'peer.create', (data) =>
            @peers[data.id] = new Peer @ws, data.id, data.name
        @ws.defineAction 'pc.offer', (data) =>
            if @peers[data.from]?
                @peers[data.from].answerHandshake data.description
        @ws.defineAction 'pc.answer', (data) =>
            if @peers[data.from]?
                @peers[data.from].concludeHandshake data.description

if window?
    if not window.Voicious?
        window.Voicious = { }
    window.Voicious.Connections = Connections

window.RTCSessionDescription = window.mozRTCSessionDescription or window.RTCSessionDescription
window.RTCIceCandidate       = window.mozRTCIceCandidate       or window.RTCIceCandidate
window.RTCPeerConnection     = window.mozRTCPeerConnection     or window.webkitRTCPeerConnection
navigator.GetUserMedia       = navigator.mozGetUserMedia       or navigator.webkitGetUserMedia
