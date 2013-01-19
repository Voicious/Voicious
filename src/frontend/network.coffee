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

networkConfig   =
            hostname  : '192.168.52.134'
            port      : 1337

class NetworkManager
    constructor   : () ->
        @connections = {}

    createPeerConnection : (options) ->
        that              = this
        cid               = options.cinfo.cid

        if localStream?
            options.stream  = localStream

        options.gotstream = (event) ->
            trace "Add new stream"
            baliseVideoId   = 'video' + cid
            baliseBlockId   = "block" + cid
            $("#videos").append('<div id="' + baliseBlockId + '" class="video-block">
                  <p>Callee - ' + cid + '</p>
                  <video id="' + baliseVideoId + '" autoplay="autoplay" class="videoStream"></video>
                </div>')
            baliseName = '#' + baliseVideoId
            $(baliseName).attr('src', window.URL.createObjectURL(event.stream));

        options.removestream = (event) ->
            trace "Remove stream"

        options.getice = (event) ->
            if (event.candidate)
              that.onSend ["candidate", options.cinfo,
              {
              type: 'candidate',
              label: event.candidate.sdpMLineIndex,
              id: event.candidate.sdpMid, candidate: event.candidate.candidate
              }]
            else
              trace "End of candidates."

        options.onCreateAnswer = (sessionDescription) ->
            that.onSend ["answer", options.cinfo, sessionDescription.sdp]

        pc  = WRTCPeerConnection options

        obj =
          peerConnection  : pc
          cinfo           : options.cinfo
        @connections[cid] = obj

    negociatePeersOffer : (stream) ->
        that = this
        for key, val of @connections
            trace "Call addStream"
            peer = val.peerConnection
            peer.addStream(stream)
            peer.peerCreateOffer (offer) ->
                that.onSend ["offer", val.cinfo, offer.sdp]

    onOpen    : () ->
        roomId = $("#infos").attr("room")
        token = $("#infos").attr("token") # delete token from the infos
        @onSend ["authentification", roomId, token]

    onMessage : (message) ->
        args        = JSON.parse(message.data)

        eventName   = args[0]
        cinfos      = args[1]
        sdp         = args[2]
        
        trace "Received : #{args}"
        switch (eventName)
            when 'peers'
              trace "on peers"
              for i in [0...cinfos.length] by 1
                cinfo = cinfos[i]

                that    = this
                options =
                  cinfo     : cinfo
                  onoffer   : (offer) ->
                    that.onSend ["offer", cinfo, offer.sdp]

                @createPeerConnection(options)
            when 'peer.create'
              trace "on peer create"

              options   =
                  cinfo   : cinfos

              @createPeerConnection(options)

            when 'peer.remove'
              trace "on peer remove"

              cinfo     = cinfos
              peerInfos = @connections[cinfo.cid]

              peerInfos.peerConnection.close()

              baliseBlockId = "#block" + cinfo.cid
              $(baliseBlockId).remove()

              #delete peerInfos.peerConnection
              delete @connections[cinfo.cid]

            when 'offer'
              trace('on offer')

              cinfo = cinfos
              peer  = @connections[cinfo.cid].peerConnection

              peer.peerCreateAnswer {sdp: sdp, type: 'offer'}

            when 'answer'
              trace "on answer"

              cinfo     = cinfos
              peerInfos = @connections[cinfo.cid]

              if peerInfos?
                peer = peerInfos.peerConnection
                peer.onanswer {sdp: sdp, type: 'answer'}

            when 'candidate'
              trace "add ice candidate"

              cinfo     = cinfos
              peerInfos = @connections[cinfo.cid]
              if peerInfos?
                peer = peerInfos.peerConnection
                peer.addice(sdp)
    
    onSend        : (message) ->
        msg = JSON.stringify message
        console.log "Send : #{msg}"
        @tunnel.send msg
    
    connection    : () ->
        that              = this
        @socket           = new WebSocket "ws://#{networkConfig.hostname}:#{networkConfig.port}/"
        @tunnel           = @socket
        @socket.onopen    = () ->
            do that.onOpen
        @socket.onmessage = (message) ->
            that.onMessage message

NM  = new NetworkManager

if window?
    window.NetworkManager     = NM
if exports?
    exports.NetworkManager    = NM