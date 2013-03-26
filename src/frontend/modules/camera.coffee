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

class   Camera extends Module
    constructor         : (NetworkManager) ->
        super NetworkManager
        $('#joinConference').click () =>
            do $('#notActivate').hide
            @joinConference()
        do @enableZoomMyCam
        do @enableZoomCam
        $('#body').css 'height', '77%' # SOOOOO BAD. Another idea ?
        $('#footer').removeClass 'none'

    joinConference      : () =>
        options =
            video       : '#localVideo'
            onsuccess   : (stream) =>
                window.localStream          = stream
                @networkManager.negociatePeersOffer stream
                $('#joinConference').attr "disabled", "disabled"
            onerror     : (e) =>
        $(options.video).removeClass 'none'
        WebRTC.getUserMedia(options)

    checkZoom   : (context, htmlClass) =>
        prevCam = $('#mainCam video')
        prevId = -1
        newId = $(context).attr('id')
        if prevCam
            prevId = prevCam.attr 'id'
        if newId + "-mainCam" isnt prevId
            do prevCam.remove
            newCam = $(context).clone()
            newCamId = newCam.attr 'id'
            newCam.attr 'id', newCamId + "-mainCam"
            newCam.removeClass htmlClass
            newCam.addClass 'mainCam'
            $('#mainCam').append newCam
            do window.Relayout

    enableZoomMyCam     : () =>
        that = this
        $('#localVideo').click () ->
            that.checkZoom this, 'localVideo'

    enableZoomCam       : () =>
        that = this
        $('#videos').delegate 'li.thumbnail video', 'click', () ->
            that.checkZoom this, 'thumbnailVideo'

CAM = Camera

if window?
    window.Camera = CAM