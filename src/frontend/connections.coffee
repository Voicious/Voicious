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
    constructor : (@uid, @rid, @emitter) ->

    dance : (ws) =>
        @ws           = new WebSocket "ws://#{ws.host}:#{ws.port}"
        @ws.onopen    = @onOpen
        @ws.onmessage = @onMessage

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
        @emitter.trigger message.type, message.params

class PC
    constructor : (@id, @ws, emitter, localStream) ->
        iceServers         = { iceServers : [ { url : 'stun:23.21.150.121' } ] }
        @constraints       =
            mandatory :
                OfferToReceiveAudio     : yes
                OfferToReceiveVideo     : yes
        @channels          = { }

        @pc                = new window.RTCPeerConnection iceServers
        @pc.onicecandidate = @onIceCandidate
        @pc.onaddstream    = (event) =>
            data =
                video : createVideoTag event.stream
                uid   : @id
            emitter.trigger 'stream.create', data
        @addStream localStream

    addStream : (s) =>
        if s?
            @pc.addStream s

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
                #if MOZILLA
                #    sdp             = description.sdp.split "\r\n"
                #    description.sdp = ''
                #    for token in sdp
                #        description.sdp += token + "\r\n"
                #        if token[0] is 'm' and token[1] is '='
                #            description.sdp += "a=crypto:1 AES_CM_128_HMAC_SHA1_80 inline:BAADBAADBAADBAADBAADBAADBAADBAADBAADBAAD\r\n"
                @ws.forward @id, { type : 'pc.offer' , params : { description : description } }
            , errorHandler
        , errorHandler, @constraints

    createAnswer : (offeredDescription) =>
        @pc.setRemoteDescription offeredDescription, () =>
            @pc.createAnswer (description) =>
                @pc.setLocalDescription description, () =>
                    @ws.forward @id, { type : 'pc.answer', params : { description : description } }
                , errorHandler
            , errorHandler, @constraints
        , errorHandler

    conclude : (answeredDescription) =>
        @pc.setRemoteDescription answeredDescription

    addIceCandidate : (label, id, candidate) =>
        @pc.addIceCandidate new window.RTCIceCandidate {
            sdpMLineIndex : label
            candidate     : candidate
        }

class Peer
    constructor : (ws, @id, @name, emitter, localStream = undefined) ->
        @pc = new PC @id, ws, emitter, localStream

    setLocalStream : (localStream) =>
        @pc.addStream localStream

    offerHandshake : () =>
        do @pc.createOffer

    answerHandshake : (offeredDescription) =>
        if MOZILLA
            @pc.createAnswer offeredDescription
        else
            @pc.createAnswer (new window.RTCSessionDescription offeredDescription)

    concludeHandshake : (answeredDescription) =>
        if MOZILLA
            @pc.conclude answeredDescription
        else
            @pc.conclude (new window.RTCSessionDescription answeredDescription)

class Connections
    constructor : (@uid, @rid, @wsPortal) ->
        @peers       = { }
        @emitter     = ($ '<span>', { display : 'none', id : 'EMITTER' })
        @ws          = new Ws @uid, @rid, @emitter
        @localStream = undefined
        @userMedia   =
            video : yes

    dance : () =>
        @ws.dance @wsPortal
        @emitter.on 'peer.list', (event, data) =>
            for peer in data.peers
                @peers[peer.id] = new Peer @ws, peer.id, peer.name, @emitter, @localStream
                do @peers[peer.id].offerHandshake
        @emitter.on 'peer.create', (event, data) =>
            @peers[data.id] = new Peer @ws, data.id, data.name, @emitter, @localStream
        @emitter.on 'pc.offer', (event, data) =>
            if @peers[data.from]?
                @peers[data.from].answerHandshake data.description
        @emitter.on 'pc.answer', (event, data) =>
            if @peers[data.from]?
                @peers[data.from].concludeHandshake data.description
        @emitter.on 'ice.candidate', (event, data) =>
            if @peers[data.from]?
                @peers[data.from].pc.addIceCandidate data.label, data.id, data.candidate

    defineAction : (actionName, action) =>
        @emitter.on actionName, action

    sendToAll : (message) =>
        message = { type : 'chat.message' , params : { message : message } }
        for id of @peers
            @ws.forward id, message

    enableCamera : (cb) =>
        navigator.getUserMedia @userMedia, (stream) =>
            @localStream = stream
            for id, peer of @peers
                peer.setLocalStream @localStream
                do peer.offerHandshake
            cb (createVideoTag stream)
        , errorHandler

window.RTCSessionDescription = window.mozRTCSessionDescription or window.RTCSessionDescription
window.RTCIceCandidate       = window.mozRTCIceCandidate       or window.RTCIceCandidate
window.RTCPeerConnection     = window.mozRTCPeerConnection     or window.webkitRTCPeerConnection
navigator.getUserMedia       = navigator.mozGetUserMedia       or navigator.webkitGetUserMedia

MOZILLA = if navigator.mozGetUserMedia? then yes else no

createVideoTag = (stream) ->
    videoTag          = document.createElement 'video'
    videoTag.autoplay = yes
    if MOZILLA
        videoTag.mozSrcObject = stream
    else
        videoTag.src          = window.URL.createObjectURL stream
    do videoTag.play
    return videoTag

errorHandler = () ->
    console.error arguments

if window?
    if not window.Voicious?
        window.Voicious = { }
    window.Voicious.Connections    = Connections
    window.Voicious.WebRTCRunnable = if window.RTCPeerConnection? and navigator.getUserMedia? then yes else no
