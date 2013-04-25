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
        @emitter     = ($ '<span>', { display : 'none', id : 'EMITTER' })
        @rid         = ($ '#infos').attr 'rid'
        @uid         = ($ '#infos').attr 'uid'
        @moduleArray = new Array
        if window.ws? and window.ws.Host? and window.ws.Port?
            @connections = new Voicious.Connections @emitter, @uid, @rid, { host : window.ws.Host, port : window.ws.Port }
            @loadModules modules, () =>
                do @connections.dance
        $('#reportBug').click @bugReport
        $('#tutorialMode').toggle @startTutorial, @stopTutorial

    # Get the javascript for the new module given in parameter
    # and call getModuleHTML.
    loadScript          : (moduleName, modules, cb) ->
        $.ajax(
            type    : 'GET'
            url     : "/public/js/#{moduleName}.js"
            dataType: 'script'
        ).done (data) =>
            eval data
            module = do (moduleName.charAt 0).toUpperCase + moduleName.slice 1
            @moduleArray.push (new window[module] @emitter)
            do @moduleArray[@moduleArray.length - 1].appendHTML
            @loadModules modules, cb

    # Load the Modules given in parameter recursively.
    # Parameter's type must be an array.
    loadModules         : (modules, cb) ->
        if modules.length != 0
            mod = do modules.shift
            @loadScript mod, modules, cb
        else
            do cb

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

# When the document has been loaded it will check if all services are available and
# launch it.
$(document).ready ->
    if window.Voicious.WebRTCRunnable
        # Resize all elements vertically when window is resized
        # (middle-row elements must fill all space between header and footer)
        resizeAll = () ->
            container     = ($ '.container-fluid')[0]
            rows          = ($ container).find '.row-fluid'
            summedHeight  = 0
            for row in rows
                if (($ row).attr 'id') isnt 'middle-row'
                    summedHeight += do ($ row).innerHeight
            jqMiddleRow   = ($ '#middle-row')
            summedPadding = (parseInt (jqMiddleRow.css 'padding-top')) + (parseInt (jqMiddleRow.css 'padding-bottom'))
            jqMiddleRow.height (do ($ window).innerHeight) - summedHeight - summedPadding
        do resizeAll
        ($ window).on 'resize', resizeAll
        room = new Room window.modules
