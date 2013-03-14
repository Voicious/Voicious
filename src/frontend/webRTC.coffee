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

# Initalize WebRTC functions into a unique function.
window.RTCPeerConnection = window.webkitRTCPeerConnection or window.mozRTCPeerConnection or window.RTCPeerConnection
window.SessionDescription = window.RTCSessionDescription or window.mozRTCSessionDescription or window.RTCSessionDescription
window.IceCandidate = window.RTCIceCandidate or window.mozRTCIceCandidate or window.RTCIceCandidate

navigator.getUserMedia = navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.getUserMedia

# Initialize WebRTC context.
window.defaults = {
    iceServers: { "iceServers": [{ "url": "stun:stun.ekiga.net" }] },
    constraints: { 'mandatory': { 'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true } }
    optional: { optional: [{ RtpDataChannels: true}] }
}

# Check if the WebRTC functions are available.
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

    # Initialize a datachannel with callbacks.
    setDataChannel          = (channel) =>
        channel.onopen      = () =>
            if options.onChannelOpen?
                do options.onChannelOpen
                peerConnection.tunnel = channel
                peerConnection.channel = channel
        channel.onmessage   = (message) =>
            if options.onChannelMessage?
                options.onChannelMessage message
        channel.onsend      = (message) =>
            if options.onChannelSend?
                options.onChannelSend channel, message
        channel.onclose     = () =>
            if options.onChannelClose?
                do options.onChannelClose
                peerConnection.tunnel = peerConnection.socket
                peerConnection.channel = null
        channel.onerror     = () =>
            if options.onChannelError?
                do options.onChannelError

    # Check if datachannels are available and create one.
    createDataChannel       = () =>
        try
            if peerConnection.createDataChannel?
                channel = peerConnection.createDataChannel 'RTCDataChannel', { reliable: false }
                setDataChannel channel
        catch err
            return

    if options.onoffer?
        do createDataChannel

    # Send ice candidate.
    onicecandidate          = (event) =>
        if !event or !event.candidate or !peerConnection
            return
        if options.getice
            options.getice peerConnection.tunnel, event

    # Add a received stream into the peerconnection.
    onaddstream             = (event) =>
        if options.gotstream?
            options.gotstream event

    # Remove a stream.
    onremovestream          = (event) =>
        if options.removestream?
            options.removestream event
            
    # Set datachannel callbacks.
    ondatachannel           = (event) =>
        setDataChannel event.channel

    peerConnection.onicecandidate   = onicecandidate
    peerConnection.onaddstream      = onaddstream
    peerConnection.onremovestream   = onremovestream
    peerConnection.ondatachannel    = ondatachannel

    if options.stream
        peerConnection.addStream options.stream

    # Create peerConnection offers and send them to a guest.
    peerConnection.peerCreateOffer = (onoffer) =>
        if onoffer?
            peerConnection.createOffer (sessionDescription) =>
                peerConnection.setLocalDescription(sessionDescription)
                onoffer(peerConnection.tunnel, sessionDescription)
            , (error) =>
                return
            , constraints

    # Create answer from offer and send the answer to the guest.
    peerConnection.peerCreateAnswer = (offer) =>
        if offer?
            peerConnection.setRemoteDescription new SessionDescription(offer)
            peerConnection.createAnswer (sessionDescription) =>
                peerConnection.setLocalDescription(sessionDescription)
                options.onCreateAnswer(peerConnection.tunnel, sessionDescription)
            , (error) =>
                return
            , constraints

    peerConnection.peerCreateOffer options.onoffer
    peerConnection.peerCreateAnswer options.offer

    # Set the peerConnection description on answer.
    peerConnection.onanswer         = (sdp) =>
          peerConnection.setRemoteDescription new SessionDescription(sdp)

    # Add new ice candidate.
    peerConnection.addice           = (candidate) => 
          peerConnection.addIceCandidate(new IceCandidate {
                sdpMLineIndex: candidate.sdpMLineIndex,
                candidate: candidate.candidate
                })
    return peerConnection

# Get audio and video from user.
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
