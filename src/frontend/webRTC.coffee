###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

window.RTCPeerConnection = window.webkitRTCPeerConnection or window.mozRTCPeerConnection or window.RTCPeerConnection
window.SessionDescription = window.RTCSessionDescription or window.mozRTCSessionDescription or window.RTCSessionDescription
window.IceCandidate = window.RTCIceCandidate or window.mozRTCIceCandidate or window.RTCIceCandidate

navigator.getUserMedia = navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.getUserMedia

window.defaults         = {
    iceServers  : { "iceServers": [{ "url": "stun:stun..org" }] },
    constraints : { 'mandatory': { 'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true } }
    optional    : { optional: [{ RtpDataChannels: true}] }
}

Runnable                = () ->
        if RTCPeerConnection? and navigator.getUserMedia?
            return true
        return false

PeerConnection          = (options) ->
    iceServers              = options.iceServers or defaults.iceServers
    constraints             = options.constraints or defaults.constraints
    optional                = options.optional or defaults.optional  

    peerConnection          = new RTCPeerConnection iceServers, optional
    
    if !peerConnection
        return null

    peerConnection.tunnel   = options.tunnel
    peerConnection.channel  = null

    setDataChannel          = (channel) =>
        channel.onopen = () =>
            if options.onChannelOpen?
                do options.onChannelOpen
                peerConnection.tunnel = channel
                peerConnection.channel = channel
        channel.onmessage = (message) =>
            if options.onChannelMessage?
                options.onChannelMessage message
        channel.onclose = () =>
            if options.onChannelClose?
                options.onChannelClose
                peerConnection.tunnel = peerConnection.socket
                peerConnection.channel = null
        channel.onerror = () =>
            if options.onChannelError?
                options.onChannelError

    createDataChannel       = () =>
        if RTCPeerConnection.prototype.createDataChannel?
            channel = peerConnection.createDataChannel 'RTCDataChannel', { reliable: false }
            setDataChannel channel
        else
            trace "DataChannels are not available on this browser"

    if options.onoffer?
        do createDataChannel

    onicecandidate          = (event) =>
        if !event or !event.candidate or !peerConnection
            return
        if options.getice
            options.getice peerConnection.tunnel, event

    onaddstream             = (event) =>
        if options.gotstream?
            options.gotstream event

    onremovestream          = (event) =>
        trace "on remove stream"
        if options.removestream?
            options.removestream event
            
    ondatachannel           = (event) =>
        setDataChannel event.channel

    peerConnection.onicecandidate   = onicecandidate
    peerConnection.onaddstream      = onaddstream
    peerConnection.onremovestream   = onremovestream
    peerConnection.ondatachannel    = ondatachannel

    if options.stream
        peerConnection.addStream options.stream

    peerConnection.peerCreateOffer = (onoffer) =>
        if onoffer?
            peerConnection.createOffer (sessionDescription) =>
                peerConnection.setLocalDescription(sessionDescription)
                onoffer(peerConnection.tunnel, sessionDescription)
            , (error) =>
                trace error
            , constraints
    peerConnection.peerCreateOffer options.onoffer

    peerConnection.peerCreateAnswer = (offer) =>
        if offer?
            peerConnection.setRemoteDescription new SessionDescription(offer)
            peerConnection.createAnswer (sessionDescription) =>
                peerConnection.setLocalDescription(sessionDescription)
                options.onCreateAnswer(peerConnection.tunnel, sessionDescription)
            , (error) =>
                trace error
            , constraints
    peerConnection.peerCreateAnswer options.offer

    peerConnection.onanswer         = (sdp) =>
          peerConnection.setRemoteDescription new SessionDescription(sdp)

    peerConnection.addice           = (candidate) => 
          peerConnection.addIceCandidate(new IceCandidate {
                sdpMLineIndex: candidate.sdpMLineIndex,
                candidate: candidate.candidate
                })
    return peerConnection

GetUserMedia            = (options) ->
    URL = window.webkitURL or window.URL

    navigator.getUserMedia(options.constraints or { audio: true, video: true },
        (stream) =>
            if (options.video)
                if (!navigator.mozGetUserMedia)
                    $(options.video).attr 'src', window.URL.createObjectURL(stream)
                else
                    $(options.video).attr 'src', stream
                options.onsuccess(stream)
    , options.onerror)

WebRTC  =
    runnable        : Runnable
    peerConnection  : PeerConnection
    getUserMedia    : GetUserMedia

if window?
    window.WebRTC   = WebRTC
if exports?
    exports.WebRTC  = WebRTC