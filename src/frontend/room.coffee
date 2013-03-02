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
    constructor         : (modules) ->
        @moduleArray = new Array
        if window.ws? and window.ws.Host? and window.ws.Port?
            @networkManager = NetworkManager window.ws.Host, window.ws.Port
            @loadModules modules
            do @enableZoomMyCam
            do @enableZoomCam
        $('#reportBug').click @bugReport
        $('#tutorialMode').toggle @startTutorial, @stopTutorial

    loadScript          : (moduleName) ->
        $('head').append "<script type='test/javascript' src='/public/js/#{moduleName}.js'>"

    getModuleHTML       : (moduleName) ->
        $.ajax(
            type    : 'POST'
            url     : '/renderModule'
            data    :
                    module      : moduleName
            ).done (data) =>
                $(data).appendTo("##{moduleName}")

    # Load the Modules given in parameter.
    # Parameter's type must be an array
    loadModules         : (modules) ->
        for module in modules
            @loadScript module
            @getModuleHTML module
            module = do (module.charAt 0).toUpperCase + module.slice 1
            @moduleArray.push (new window[module] @networkManager)

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
        room = new Room window.modules
        do room.start

    container   = ($ '#page')
    relayout    = Relayout container
    ($ window).resize relayout
    if window?
        window.Relayout = relayout
