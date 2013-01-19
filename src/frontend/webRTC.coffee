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

window.PeerConnection = window.webkitRTCPeerConnection || window.mozRTCPeerConnection || window.RTCPeerConnection
window.SessionDescription = window.RTCSessionDescription || window.mozRTCSessionDescription || window.RTCSessionDescription
window.IceCandidate = window.RTCIceCandidate || window.mozRTCIceCandidate || window.RTCIceCandidate

navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.getUserMedia

window.defaults = {
    iceServers: { "iceServers": [{ "url": "stun:stun.l.google.com:19302" }] },
    constraints: { 'mandatory': { 'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true } }
}

createPeerConnection = (options) ->
    iceServers      = options.iceServers || defaults.iceServers
    constraints     = options.constraints || defaults.constraints

    peerConnection  = new PeerConnection iceServers

    onicecandidate  = (event) ->
        if !event.candidate || !peerConnection
            return
        if options.getice
            options.getice event

    onaddstream = (event) ->
        if options.gotstream?
            options.gotstream event

    onremovestream = (event) ->
        console.log "on remove stream"
        if options.removestream?
            options.removestream event

    peerConnection.onicecandidate = onicecandidate
    peerConnection.onaddstream = onaddstream
    peerConnection.onremovestream = onremovestream

    if options.stream
        console.log "add stream"
        peerConnection.addStream options.stream

    peerConnection.peerCreateOffer = (onoffer) ->
        if onoffer?
            peerConnection.createOffer (sessionDescription) ->
                peerConnection.setLocalDescription(sessionDescription)
                onoffer(sessionDescription)
            , null, constraints
    peerConnection.peerCreateOffer options.onoffer

    peerConnection.peerCreateAnswer = (offer) ->
        if offer?
            peerConnection.setRemoteDescription new SessionDescription(offer)
            peerConnection.createAnswer (sessionDescription) ->
                peerConnection.setLocalDescription(sessionDescription)
                options.onCreateAnswer(sessionDescription)
            , (error) ->
                console.log error
            , constraints
    peerConnection.peerCreateAnswer options.offer

    peerConnection.onanswer = (sdp) ->
          peerConnection.setRemoteDescription new SessionDescription(sdp)

    peerConnection.addice = (candidate) -> 
          peerConnection.addIceCandidate(new IceCandidate {
                sdpMLineIndex: candidate.sdpMLineIndex,
                candidate: candidate.candidate
                })
    return peerConnection

getUserMedia = (options) ->
    URL = window.webkitURL || window.URL

    if navigator.getUserMedia?
      navigator.getUserMedia(options.constraints || { audio: true, video: true },
        (stream) ->
            if (options.video)
                if (!navigator.mozGetUserMedia)
                    options.video.src = @URL.createObjectURL(stream)
                else
                    options.video.mozSrcObject = stream
            if options.onsuccess?
                options.onsuccess(stream)
            return stream

        , options.onerror)
    else
      console.log "GetUserMedia is not available"
            
PC  = createPeerConnection
M   = getUserMedia

if window?
    window.WRTCPeerConnection   = PC
    window.Media                = M
if exports?
    exports.WRTCPeerConnection  = PC
    exports.Media               = M