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

class NetworkManager
    constructor             : (hostname, port) ->
        @networkConfig              = {}
        @networkConfig.hostname     = hostname
        @networkConfig.port         = port
        @connections                = {}
        @queue                      = new Queue

    autoZoomWebcam          : () =>
        mainCamId = $('#mainCam video').attr 'id'
        if not mainCamId
            video = $('#videos li.thumbnail').first()
            newCam = $(video).find("video").clone()
            newCamId = newCam.attr 'id'
            newCam.attr 'id', newCamId + "-mainCam"
            newCam.removeClass 'thumbnailVideo'
            newCam.addClass 'mainCam'
            $('#mainCam').append newCam

    createPeerConnection    : (options) =>
        cid               = options.cinfo.cid
        localStream       = window.localStream

        if localStream?
            options.stream = localStream

        options.tunnel              = @socket
        options.onChannelOpen       = @onChannelOpen
        options.onChannelMessage    = (message) =>
            @onChannelMessage message
        options.onChannelSend       = @onChannelSend
        options.onChannelClose      = @onChannelClose
        options.gotstream           = (event) =>
            baliseVideoId       = 'video' + cid
            baliseBlockId       = "block" + cid
            $("#videos").append(
                '<li id="' + baliseBlockId + '" class="thumbnail">
                    <p class="none">Callee - ' + cid + '</p>
                     <video id="' + baliseVideoId + '" autoplay="autoplay" class="thumbnailVideo"></video>
                 </li>'
                )
            baliseName          = '#' + baliseVideoId
            $(baliseName).attr 'src', window.URL.createObjectURL(event.stream)
            do @autoZoomWebcam
        options.removestream        = (event) =>
            return
        options.getice              = (tunnel, event) =>
            if (event.candidate)
                tunnel.onsend ["candidate", options.cinfo,
                {
                    type: 'candidate',
                    label: event.candidate.sdpMLineIndex,
                    id: event.candidate.sdpMid, candidate: event.candidate.candidate
                }]
        options.onCreateAnswer      = (tunnel, sessionDescription) =>
            tunnel.onsend ["answer", options.cinfo, sessionDescription.sdp]

        pc  = WebRTC.peerConnection options

        if pc?
            pc.socket = @socket

            obj =
              peerConnection  : pc
              cinfo           : options.cinfo
            @connections[cid] = obj
            return obj
        return null

    sendToAll                   : (message) =>
        for key, val of @connections
            do (key, val) =>
                message[1] = val.cinfo
                pc = val.peerConnection
                pc.tunnel.onsend message

    negociatePeersOffer         : (stream) =>
        for key, val of @connections
            do (key, val) =>
                pc = val.peerConnection
                pc.addStream(stream)
                pc.peerCreateOffer (tunnel, offer) =>
                    tunnel.onsend ["offer", val.cinfo, offer.sdp]

    onSocketOpen                : () =>
        roomId = $("#infos").attr("room")
        token = $("#infos").attr("token")
        @socket.onsend ["authentification", roomId, token]

    onChannelOpen               : () =>

    onSocketMessage             : (message) =>
        try
            args        = JSON.parse(message.data)
        catch err
            return

        eventName   = args[0]
        cinfos      = args[1]
        infos       = args[2]

        if eventName? and cinfos?
            @onMessagePeers eventName, cinfos
            if infos?
                @onMessageExchangeOffer eventName, cinfos, infos
                @onMessageText eventName, cinfos, infos

    buildMessage                : (args) =>
        id      = args[1]
        nb      = args[2]
        nbMax   = args[3]
        elem    = args[4]

        @queue.addMsgInQueue id, nb, elem

        queueLength = Utilities.getMapSize @queue.queue[id]

        if @queue.queue[id]? and queueLength == nbMax
            msg = ""
            for key, val of @queue.queue[id]
                msg += val
            return msg
        else
            return null

    onChannelMessage            : (message) =>
        try
            args        = JSON.parse(message.data)
        catch err
            return

        msg         = null
        eventName   = args[0]

        if eventName == "chunkMsg"
            msg     = @buildMessage args
            args    = JSON.parse(msg)
        if eventName != "chunkMsg" or msg?
            eventName   = args[0]
            cinfos      = args[1]
            infos       = args[2]

            if eventName? and cinfos? and infos?
                @onMessageExchangeOffer eventName, cinfos, infos
                @onMessageText eventName, cinfos, infos

    onMessagePeers              : (eventName, cinfos) =>
        switch (eventName)
            when 'peers'
                cinfos.forEach (cinfo, i) =>
                    options =
                        cinfo     : cinfo
                        onoffer   : (tunnel, offer) =>
                            tunnel.onsend ["offer", cinfo, offer.sdp]

                    @createPeerConnection options
                event = EventManager.getEvent "fillUsersList"
                if event?
                    event @connections
            when 'peer.authentification'
                @cinfo = cinfos
            when 'peer.create'
                options   =
                    cinfo   : cinfos

                peerInfos = @createPeerConnection options

                if peerInfos?
                    event = EventManager.getEvent "updateUserList"
                    if event?
                        event peerInfos, "create"
            when 'peer.remove'
                cinfo     = cinfos
                peerInfos = @connections[cinfo.cid]

                event = EventManager.getEvent "updateUserList"
                if event?
                    event peerInfos, "remove"

                peerInfos.peerConnection.close()

                baliseBlockId = "#block" + cinfo.cid
                $(baliseBlockId).remove()
                mainCamId = $('#mainCam video').attr 'id'
                console.log mainCamId
                console.log "video" + cinfo.cid + "-mainCam"
                if mainCamId is "video" + cinfo.cid + "-mainCam"
                    $("#mainCam video").remove()
                    do @autoZoomWebcam

                delete @connections[cinfo.cid]

    onMessageExchangeOffer      : (eventName, cinfos, sdp) =>
        switch (eventName)
            when 'offer'
                cinfo = cinfos
                pc    = @connections[cinfo.cid].peerConnection

                pc.peerCreateAnswer {sdp: sdp, type: 'offer'}

            when 'answer'
                cinfo     = cinfos
                peerInfos = @connections[cinfo.cid]

                if peerInfos?
                    pc = peerInfos.peerConnection
                    pc.onanswer {sdp: sdp, type: 'answer'}

            when 'candidate'
                cinfo       = cinfos
                pc          = @connections[cinfo.cid].peerConnection

                pc.addice sdp

    onMessageText               : (eventName, cinfos, msg) =>
        switch eventName
            when 'message'
                event = EventManager.getEvent 'receiveTextMessage'
                if event?
                    event msg

    onSocketClose               : () =>

    onChannelClose              : (event) =>

    onSocketSend                : (socket, message) =>
        msg = JSON.stringify message
        socket.send msg

    onChannelSend               : (channel, message) =>
        message[1].cid = @cinfo.cid
        msg = JSON.stringify message
        if msg.length > 1000
            arr = Utilities.splitString msg, 500
            id  = do Utilities.generateRandomId
            i   = 1
            for elem in arr
                chunk = JSON.stringify ['chunkMsg', id, i, arr.length, elem]
                channel.send chunk
                i++
        else
            channel.send msg

    connection                  : () =>
        @socket             = new WebSocket "ws://#{@networkConfig.hostname}:#{@networkConfig.port}/"
        @socket.onopen      = () =>
            do @onSocketOpen
        @socket.onmessage   = (message) =>
            @onSocketMessage message
        @socket.onsend      = (message) =>
            @onSocketSend @socket, message
        @socket.onclose     = () =>
            do @onSocketClose

NM  = (hostname, port) ->
    new NetworkManager hostname, port

if window?
    window.NetworkManager     = NM
if exports?
    exports.NetworkManager    = NM
