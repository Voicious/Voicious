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

    # Auto zoom web cam when a new peer join the conference.
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

    # Create a new peerConnection.
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
                     <video id="' + baliseVideoId + '" autoplay="autoplay" class="thumbnailVideo flipH"></video>
                 </li>'
                )
            baliseName          = '#' + baliseVideoId
            $(baliseName).attr 'src', window.URL.createObjectURL(event.stream)
            feed = $("#nbFeed").text()
            feed = Number(feed) + 1
            $("#nbFeed").text(feed)
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

    # Send a packet to all the peers connected to the room.
    sendToAll                   : (message) =>
        for key, val of @connections
            do (key, val) =>
                message[1] = val.cinfo
                pc = val.peerConnection
                pc.tunnel.onsend message

    # Negociate peers offer with all the peers connected to the room.
    negociatePeersOffer         : (stream) =>
        for key, val of @connections
            do (key, val) =>
                pc = val.peerConnection
                pc.addStream(stream)
                pc.peerCreateOffer (tunnel, offer) =>
                    tunnel.onsend ["offer", val.cinfo, offer.sdp]

    # Send authentification packet when the socket open.
    onSocketOpen                : () =>
        roomId = $("#infos").attr("room")
        token = $("#infos").attr("token")
        @socket.onsend ["authentification", roomId, token]

    onChannelOpen               : () =>

    # Called when a new packet has been received on the socket.
    # Check the packet content when receving a new message.
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

    # Build a packet from a complete queue.
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

    # Called when a new packet has been received on the datachannel.
    # Check the packet content when receiving a new message.
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

    # Call the functions related to the connection of a new peer or a disconnection.
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
                if mainCamId is "video" + cinfo.cid + "-mainCam"
                    $("#mainCam video").remove()
                    do @autoZoomWebcam

                feed = $("#nbFeed").text()
                feed = Number(feed) - 1
                if feed < 0
                    feed = 0
                $("#nbFeed").text(feed)
                delete @connections[cinfo.cid]

    # Call the functions related to the peerConnection exchange.
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

    # Call the functions related to the text chat.
    onMessageText               : (eventName, cinfos, msg) =>
        switch eventName
            when 'message'
                event = EventManager.getEvent 'receiveTextMessage'
                if event?
                    event msg

    onSocketClose               : () =>

    onChannelClose              : (event) =>

    # Send a message to a peer through a socket.
    onSocketSend                : (socket, message) =>
        msg = JSON.stringify message
        socket.send msg

    # Send a message to a peer through a datachannel.
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

    # Start the network services.
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
