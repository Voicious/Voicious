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
localStream = 0

peerConnections = []
peerConnections.find = (uid) ->
  for i in [0...peerConnections.length] by 1
    peerInfos = peerConnections[i]
    if (peerInfos.uid is uid)
      return peerInfos

socket = new WebSocket('ws://192.168.52.134:1337/')

sendMessage = (message) ->
  mymsg = JSON.stringify(message)
  trace("SEND: " + mymsg)
  socket.send(mymsg)

onMessage = (evt) ->
  trace("RECEIVED: " + evt.data)
  processSignalingMessage(evt.data)

trace = (text) ->
  console.log "#{text}"

$(document).ready ->
  socket.addEventListener("message", onMessage, false)

  localVideo = $('#localVideo')

  btn1.disabled = false
  btn2.disabled = true

  $('#btn1').click () =>
     joinConference()
#  $('#btn2').click () =>
#     hangUp()

joinConference = ->
  options =
    video: localVideo
    onsuccess: successLoadMedia
    onerror: failLoadMedia

  getUserMedia(options)

failLoadMedia = (e) ->
  trace "Video or audio are not available#{e}."

successLoadMedia = (stream) ->
  trace "Success to load video."
  
  btn1.disabled = true
  btn2.disabled = false
  
  localStream = stream

  console.log peerConnections.length
  peerConnections.forEach (peerInfos, i) ->
    trace "Call addStream"
    peer = peerInfos.peerConnection
    peer.addStream(stream)
    peer.peerCreateOffer((offer) ->
      sendMessage(["offer", peerInfos.uid, offer.sdp]))

createPeerConnection = (uid, options) ->
  if localStream
    options.stream = localStream

  options.gotstream = (event) ->
    trace "Add new stream"
    baliseVideoId = 'video' + uid
    baliseBlockId = "block" + uid
    $("#videos").append('<div id="' + baliseBlockId + '" class="video-block">
          <p>Callee - ' + uid + '</p>
          <video id="' + baliseVideoId + '" autoplay="autoplay" class="videoStream"></video>
        </div>')
    baliseName = '#' + baliseVideoId
    $(baliseName).attr('src', window.URL.createObjectURL(event.stream));
    
  options.removestream = (event) ->
    trace "Remove stream"
    
  options.getice = (event) ->
    if (event.candidate)
      sendMessage(["candidate", uid, {type: 'candidate', label: event.candidate.sdpMLineIndex, id: event.candidate.sdpMid, candidate: event.candidate.candidate}])
    else
      trace "End of candidates."

  options.onCreateAnswer = (sessionDescription) ->
    sendMessage(["answer", uid, sessionDescription.sdp])

  pc = RTCPeerConnection(options)

  obj =
    peerConnection: pc
    uid: uid
  peerConnections.push(obj)

processSignalingMessage = (message) ->
  args = JSON.parse(message)

  eventName = args[0]
  uids = args[1]
  sdp = args[2]

  switch (eventName)
    when 'peers'
      trace "on peers"
      for i in [0...uids.length] by 1
        uid = uids[i]
        
        options =
          onoffer: (offer) ->
            sendMessage(["offer", uid, offer.sdp])

        createPeerConnection(uid, options)
    when 'peer.create'
      trace "on peer create"
      
      uid = uids
      options = {}
      
      createPeerConnection(uid, options)
      
    when 'peer.remove'
      trace "on peer remove"
      
      uid = uids
      peerInfos = peerConnections.find(uid)
      
      peerInfos.peerConnection.close()
      
      baliseBlockId = "#block" + uid
      $(baliseBlockId).remove()
      
      delete peerInfos.peerConnection
      peerConnections.splice(peerConnections.indexOf(peerInfos), 1)
      
    when 'offer'
      trace('on offer')

      uid = uids
      peer = peerConnections.find(uid).peerConnection

      peer.peerCreateAnswer({sdp: sdp, type: 'offer'})

    when 'answer'
      trace "on answer"

      uid = uids
      peerInfos = peerConnections.find(uid)
      
      if peerInfos?
        peer = peerInfos.peerConnection
        peer.onanswer({sdp: sdp, type: 'answer'})

    when 'candidate'
      trace "add ice candidate"

      uid = uids
      peerInfos = peerConnections.find(uid)
      if peerInfos?
        peer = peerInfos.peerConnection
        peer.addice(sdp)