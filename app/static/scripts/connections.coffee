###

Copyright (c) 2011-2013  Voicious

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
        message = JSON.parse message.data
        @emitter.trigger message.type, message.params

    close : () =>
        do @ws.close

class PeerJs
    constructor     : (@uid, @rid, @emitter) ->

    dance           : (pjs) =>
        @pjs    = new Peer @uid, { host: pjs.host, port: pjs.port }
        @pjs.on 'connection', @onConnection

    onConnection    : (conn) =>
        peer = new PC conn, @emitter

    connect         : (peerUid) =>
        conn = @pjs.connect peerUid
        peer = new PC conn, @emitter

class PC
    constructor : (@conn, @emitter) ->
        @conn.on 'open', @onOpen
        @conn.on 'data', @onData

    onOpen      : () =>
        @send 'peer.uid', {}

    onData      : (data) =>
        if data.type is 'peer.uid'
            data.peer = @
        @emitter.trigger data.type, data

    send        : (type, data) =>
        @conn.send { type: type, data: data }

    close       : () =>
        do @conn.close

class Connections
    constructor : (@emitter, @uid, @rid, @wsPortal, @pjsPortal) ->
        @peers       = { }
        @ws          = new Ws @uid, @rid, @emitter
        @pjs         = new PeerJs @uid, @rid, @emitter
        @localStream = undefined
        @userMedia   =
            video : no
            audio : no
        @emitter.on 'message.sendtoall', @sendToAll
        @emitter.on 'message.sendToOneName', @sendToOneName
        @emitter.on 'message.sendToOneId', @sendToOneId
        @emitter.on 'authenticated', @initUser
        window.onClose = () =>
            do @ws.close
            for peer in @peers
                do peer.close

    modifyStream : () =>
        if @localStream isnt undefined
            do @localStream.stop
            for id, peer of @peers

                # peer.rmLocalStream @localStream
                # do peer.offerHandshake
                if @userMedia['video'] is no or @userMedia['audio'] is no
                    @sendStreamState id
        @localStream = undefined # erase old stream
        if @userMedia['video'] is yes or @userMedia['audio'] is yes
            do @enableCamera

    initUser : (event, data) =>
        window.Voicious.currentUser = data
        @emitter.trigger 'module.initialize', { }
        
    removePeer   : (peerId) =>
        do @peers[peerId].close
        @peers[peerId] = null
        delete @peers[peerId]

    toggleCamera : () =>
        @userMedia['video'] = !@userMedia['video']

    toggleMicro : () =>
        @userMedia['audio'] = !@userMedia['audio']

    dance : () =>
        @ws.dance @wsPortal
        @pjs.dance @pjsPortal
        @emitter.on 'peer.list', (event, data) =>
            for peer in data.peers
                @pjs.connect peer.id
        @emitter.on 'peer.uid', (event, data) =>
            @peers[data.peer.peer] = data.peer
            @sendStreamState data.peer.peer
        @emitter.on 'peer.remove', (event, data) =>
            if @peers[data.id]?
                @removePeer data.id
                @emitter.trigger 'stream.remove', data
        @emitter.on 'ping', (event, data) =>
            @ws.send { type : 'pong' , params : { token : data.token } }

    sendToAll : (event, data) =>
        message
        if data.type?
            message = data
        else
            message = { type : 'chat.message' , params : { message : data } }
        for id of @peers
            @ws.forward id, message
    
    sendToOneName : (event, msg) =>
        message = { type : msg.type, params : msg.params }
        userId = @getIdFromUsername msg.to
        if userId is undefined
            @emitter.trigger 'chat.error', { text : 'kick: ' + msg.to + ' isn\'t in this room.' }
        else    
            @ws.forward userId, message

    sendToOneId : (event, msg) =>
        message = { type : msg.type, params : msg.params }
        @ws.forward msg.to, message

    sendStreamState : (id) =>
        @ws.forward id, { type : 'stream.state', params : { streamState : @userMedia } }

    enableCamera : () =>
        navigator.getUserMedia @userMedia, (stream) =>
            @emitter.trigger 'activable.unlock', @userMedia
            if not MOZILLA and not $('p#messageCam').hasClass "hidden"
                $('p#messageCam').addClass "hidden"
            @localStream = stream
            for id, peer of @peers
                peer.setLocalStream @localStream
                do peer.offerHandshake
                @sendStreamState id
            @emitter.trigger 'camera.localstream', (createVideoTag stream)
        , (error) =>
            do @toggleCamera if @userMedia.video
            do @toggleMicro if @userMedia.audio
            @emitter.trigger 'notif.text.ko',
                text : "It seems that we can't access your hardware."
            @emitter.trigger 'activable.unlock'
            if not MOZILLA and $('p#messageCam').hasClass "hidden"
                $('p#messageCam').removeClass "hidden"

    getIdFromUsername : (username) =>
        id = undefined
        for p, peer of @peers
            if peer.name is username
                id = peer.id
                break
        id    

window.RTCSessionDescription = window.mozRTCSessionDescription or window.RTCSessionDescription
window.RTCIceCandidate       = window.mozRTCIceCandidate       or window.RTCIceCandidate
window.RTCPeerConnection     = window.mozRTCPeerConnection     or window.webkitRTCPeerConnection
navigator.getUserMedia       = navigator.mozGetUserMedia       or navigator.webkitGetUserMedia

MOZILLA = if navigator.mozGetUserMedia? then yes else no

createVideoTag = (stream) ->
    videoTag          = document.createElement 'video'
    videoTag.setAttribute 'data-streamid', stream.id
    videoTag.autoplay = yes
    if MOZILLA
        videoTag.mozSrcObject = stream
    else
        videoTag.src          = window.URL.createObjectURL stream
    do videoTag.play
    return videoTag

errorHandler = (error) ->
    console.error error

if window?
    if not window.Voicious?
        window.Voicious = { }
    window.Voicious.Connections    = Connections
    window.Voicious.WebRTCRunnable = if window.RTCPeerConnection? and navigator.getUserMedia? then yes else no
