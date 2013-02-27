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
        if window.ws? and window.ws.Host? and window.ws.Port?
            @networkManager = NetworkManager window.ws.Host, window.ws.Port
            @textChat       = new TextChat @networkManager
        $('#reportBug').click @bugReport
        $('#tutorialMode').toggle @startTutorial, @stopTutorial
        do @configureEvents
        do @enableZoomMyCam
        do @enableZoomCam

    # Fill the eventManager with callbacks which need to be called outside of this object.
    configureEvents     : () =>
        EventManager.addEvent "fillUsersList", (users) =>
            @userList.fill users
        EventManager.addEvent "updateUserList", (user, event) =>
            @userList.update user, event

    # Add the user video and sound to the conference.
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

    # Check if the selected camera can be zoomed.
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

    # Enable the zoom on the main camera.
    enableZoomMyCam     : () =>
        that = this
        $('#localVideo').click () ->
            that.checkZoom this, 'localVideo'

    # Enable the zoom on the guest selected.
    enableZoomCam       : () =>
        that = this
        $('#videos').delegate 'li.thumbnail video', 'click', () ->
            that.checkZoom this, 'thumbnailVideo'

    # Start animation.
    startAnimation       : (elems, interval, speed) =>
        i = elems.length
        time = interval * 5
        while i >= 0
            $(elems[i]).delay(time).fadeIn speed
            time -= interval
            i--
        i = elems.length
        fadeOutTime = interval * 10
        while i >= 0
            $(elems[i]).delay(fadeOutTime).fadeOut speed
            fadeOutTime -= interval
            i--
        $('div#endMessage').delay(interval * 10 + 4 * interval).fadeIn speed
        $('div#endMessage').delay(interval * 10).fadeOut speed
        $('div#body').append '<div id="reportBugArrow" class="arrow_box">Click here if you want to report a bug.</div>'
        $('div#body').append '<div id="textChatArrow" class="arrow_box">Here you can chat with you friends!</div>'
        $('div#footer').append '<div id="activateArrow" class="arrow_box">Click here to activate your camera.</div>'
        $('div#body').append '<div id="userListArrow" class="arrow_box">Here is a list of users currently in the room.</div>'
        i = 0
        time = interval * 5
        while i < elems.length
            $(elems[i]).delay(time).fadeOut speed
            i++
        $('div#endMessage').delay(time).fadeIn speed
        $('div#endMessage').delay(time).fadeOut speed
        i = 0
        time = interval * 5
        while i < elems.length
            $(elems[i]).delay(time).fadeOut speed
            i++
        $('div#endMessage').delay(time).fadeIn speed
        $('div#endMessage').delay(time).fadeOut speed
        @startAnimation $("div[id$='Arrow']"), 1000, 400

    # Start the tutorial animation.
    startTutorial      : () =>
        $("#tutorialMode").css "background-color", "#43535a"
        $("#tutorialMode").css "box-shadow", "inset 0 1px #43535a"
        elems      = $("div[id$='Arrow']")
        interval   = 2000
        speed      = 400
        i          = elems.length
        fadeInTime = interval * 5
        while i >= 0
            $(elems[i]).animate({opacity: 1}, fadeInTime).fadeIn speed
            fadeInTime -= interval
            i--
        i = 0
        fadeOutTime = interval * 5
        while i < elems.length
            $(elems[i]).animate({opacity: 1}, fadeOutTime).fadeOut speed
            i++
        $('div#endMessage').animate({opacity: 1}, fadeOutTime * 2).fadeIn speed
        $('div#endMessage').animate({opacity: 1}, 2000).fadeOut speed
        setTimeout @colorTutorialBtn, fadeOutTime * 2 + 3200

    # Stop tutorial animation.
    stopTutorial      : () =>
        elems      = $("div[id$='Arrow']")
        i = 0
        while i < elems.length
            $(elems[i]).stop(true, true).fadeOut 400
            i++
        $('div#endMessage').stop(true, true).fadeOut 400
        do @colorTutorialBtn

    # Color the tutorial button.
    colorTutorialBtn   : () =>
        $("#tutorialMode").css "background-color", "#00aeef"
        $("#tutorialMode").css "box-shadow", "inset 0 1px #15DBCB"

    # Send bug report.
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

    # Hide the bug report button.
    hideReport        : () =>
        $("#reportBugCtn").addClass 'none'
        $('div.fullscreen').addClass 'none'

    # Initalize the bug report button.
    bugReport           : (event) =>
        fullscreen = $('div.fullscreen')
        fullscreen.removeClass 'none'
        fullscreen.click @hideReport
        $('#reportBugCtn').removeClass 'none'
        $('#sendReport').click @sendReport

    # Start all the room services.
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

# When the document has been loaded it will check if all services are available and
# launch it.
$(document).ready ->
    if do WebRTC.runnable == true
        room = new Room
        do room.start

    container   = ($ '#page')
    relayout    = Relayout container
    ($ window).resize relayout
    if window?
        window.Relayout = relayout
