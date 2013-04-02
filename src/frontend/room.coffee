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
    # Initialize a room and a networkManager.
    # Load the modules given in parameter (Array)
    constructor         : (modules) ->
        @moduleArray = new Array
        if window.ws? and window.ws.Host? and window.ws.Port?
            @networkManager = NetworkManager window.ws.Host, window.ws.Port
            do @networkManager.connection # Must be done before initializing modules.
            @loadModules modules
        $('#reportBug').click @bugReport

    # Get the javascript for the new module given in parameter
    # and call getModuleHTML.
    loadScript          : (moduleName, modules) ->
        $.ajax(
            type    : 'GET'
            url     : "/public/js/#{moduleName}.js"
            dataType: 'script'
        ).done (data) =>
            eval data
            @getModuleHTML moduleName, modules

    #Retrieve the HTML for the module and position it into a tag
    #   with the id #moduleName.
    # Call @loadModules with the remaining modules to load.
    getModuleHTML       : (moduleName, modules) ->
        $.ajax(
            type    : 'POST'
            url     : '/renderModule'
            data    :
                    module      : moduleName
        ).done (data) =>
            $(data).appendTo "##{moduleName}"
            module = do (moduleName.charAt 0).toUpperCase + moduleName.slice 1
            @moduleArray.push (new window[module] @networkManager)
            @loadModules modules

    # Load the Modules given in parameter recursively.
    # Parameter's type must be an array.
    loadModules         : (modules) ->
        if modules.length != 0
            mod = do modules.shift
            @loadScript mod, modules

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

    container   = ($ '#page')
    relayout    = Relayout container
    ($ window).resize relayout
    if window?
        window.Relayout = relayout
