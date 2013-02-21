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

class Room
    constructor         : () ->
        @userList       = new UserList
        @textChat       = new TextChat @networkManager
        @networkManager = NetworkManager '192.168.1.65', 4244
        $('#reportBug').click @bugReport
        do @configureEvents
        do @enableZoomMyCam
        do @enableZoomCam

    configureEvents     : () =>
        EventManager.addEvent "fillUsersList", (users) =>
            @userList.fill users
        EventManager.addEvent "updateUserList", (user, event) =>
            @userList.update user, event

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

    start               : () =>
        do @networkManager.connection
        $('#joinConference').click () =>
            do $('#notActivate').hide
            @joinConference()

    sendReport          : () =>
        $('#sendReport').attr 'disabled', on
        textArea = $('#reportBugTextarea')
        content = do textArea.val
        content = content.replace(/(^\s*)|(\s*$)/gi,"");
        content = content.replace(/[ ]{2,}/gi," ");
        if content isnt ""
            $.ajax
                type: 'POST'
                url: '/report'
                data:
                    bug: content
            textArea.val ""
            do @hideReport
        $('#sendReport').attr 'disabled', off

    hideReport        : () =>
        $("#reportBugCtn").addClass 'none'
        $('div.fullscreen').addClass 'none'

    bugReport           : (event) =>
        fullscreen = $('div.fullscreen')
        fullscreen.removeClass 'none'
        fullscreen.click @hideReport
        $('#reportBugCtn').removeClass 'none'
        $('#sendReport').click @sendReport

    start               : () =>
        do @networkManager.connection
        $('#joinConference').click () =>
            do $('#notActivate').hide
            @joinConference()

Relayout    = (container) =>
    options =
        resize : no
        type   : 'border'
    container.layout options
    return () =>
        container.layout options

$(document).ready ->
    if do WebRTC.runnable == true
        room = new Room
        do room.start

    container   = ($ '#page')
    relayout    = Relayout container
    ($ window).resize relayout
    if window?
        window.Relayout = relayout
###
    ($ '#footer').resizable {
        handles   : 'n',
        stop      : relayout,
        minHeight : 125
    }
###
