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
    constructor : (@uid, @rid) ->
        @actions      = { }

    dance : (ws) =>
        @ws           = new WebSocket "ws://#{ws.host}:#{ws.port}"
        @ws.onopen    = @onOpen
        @ws.onmessage = @onMessage

    defineAction : (actionName, callback) =>
        if not @actions[actionName]?
            @actions[actionName] = []
        @actions[actionName].push callback

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
            for i, callback of @actions[message.type]
                callback message.params

class PC
    constructor : (@id, @ws) ->
        iceServers         = { iceServers : [ { url : 'stun:23.21.150.121' } ] }
        @constraints       =
            mandatory :
                OfferToReceiveAudio : yes
                OfferToReceiveVideo : yes
        @channels          = { }

        @pc                = new window.RTCPeerConnection iceServers
        @pc.onicecandidate = @onIceCandidate

    onIceCandidate : (event) =>
        if event.candidate?
            @ws.forward @id, { type : 'ice.candidate' , params : {
                label     : event.candidate.sdpMLineIndex
                id        : event.candidate.sdpMid
                candidate : event.candidate.candidate
            } }

    createDataChannel : (name) =>
        @channels              = @pc.createDataChannel name, { }

        @channels[name].onopen = () =>
            console.log "OPENED"

    createOffer : () =>
        @pc.createOffer (description) =>
            @pc.setLocalDescription description, () =>
                @ws.forward @id, { type : 'pc.offer' , params : { description : description } }
            , (error) =>
                return
        , (error) =>
            return
        , @constraints

    createAnswer : (offeredDescription) =>
        @pc.setRemoteDescription offeredDescription, () =>
            @pc.createAnswer (description) =>
                @pc.setLocalDescription description, () =>
                    @ws.forward @id, { type : 'pc.answer', params : { description : description } }
                , (error) =>
                    return
            , (error) =>
                return
        , (error) =>
            return

    conclude : (answeredDescription) =>
        @pc.setRemoteDescription answeredDescription

    addIceCandidate : (label, id, candidate) =>
        @pc.addIceCandidate new window.RTCIceCandidate {
            sdpMLineIndex : label
            candidate     : candidate
        }

class Peer
    constructor : (ws, @id, @name) ->
        @pc = new PC @id, ws

    offerHandshake : () =>
        do @pc.createOffer

    answerHandshake : (offeredDescription) =>
        @pc.createAnswer (new window.RTCSessionDescription offeredDescription)

    concludeHandshake : (answeredDescription) =>
        @pc.conclude (new window.RTCSessionDescription answeredDescription)

class Connections
    constructor : (@uid, @rid, @wsPortal) ->
        @peers = { }
        @ws    = new Ws @uid, @rid

    dance : () =>
        @ws.dance @wsPortal
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
        @ws.defineAction 'ice.candidate', (data) =>
            if @peers[data.from]?
                @peers[data.from].pc.addIceCandidate data.label, data.id, data.candidate

    defineAction : (actionName, action) =>
        @ws.defineAction actionName, action

window.RTCSessionDescription = window.mozRTCSessionDescription or window.RTCSessionDescription
window.RTCIceCandidate       = window.mozRTCIceCandidate       or window.RTCIceCandidate
window.RTCPeerConnection     = window.mozRTCPeerConnection     or window.webkitRTCPeerConnection
navigator.getUserMedia       = navigator.mozGetUserMedia       or navigator.webkitGetUserMedia

if window?
    if not window.Voicious?
        window.Voicious = { }
    window.Voicious.Connections    = Connections
    window.Voicious.WebRTCRunnable = if window.RTCPeerConnection? and navigator.getUserMedia? then yes else no
