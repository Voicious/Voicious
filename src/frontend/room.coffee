###

Copyright (c) 2011-2013  Voicious

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
        @rid         = window.Voicious.room
        @uid         = window.Voicious.currentUser.uid
        @moduleArray = new Array

        do @setPage
        if window.ws? and window.ws.Host? and window.ws.Port?
            @connections = new Voicious.Connections @emitter, @uid, @rid, { host : window.ws.Host, port : window.ws.Port }
            @loadModules modules, () =>
                do @connections.dance
        $('#reportBug').click @bugReport

    setPage             : () ->
        $('#sidebarAcc').accordion { active: false, collapsible: true }
        $('a#shareRoomLink, a#manageRoomLink').click () ->
            elem = ($ this)
            elem.toggleClass 'down'
            jqSiblinsA = elem.siblings 'a'
            jqSiblinsA.removeClass 'down'

        ($ 'a.activable').click () ->
            jqA = ($ this).find 'span'
            icon = do jqA.first
            label = do jqA.last
            if (do label.text) is 'OFF'
                icon.removeClass 'dark-grey'
                icon.addClass 'white'
                label.text 'ON'
                label.css 'color', 'green'
            else
                icon.removeClass 'white'
                icon.addClass 'dark-grey'
                label.text 'OFF'
                label.css 'color', 'red'
        ($ '#cam').click () =>
            console.log 'On a cliqué Cam'
            do @connections.toggleCamera
        ($ '#mic').click () =>
            console.log 'On a cliqué mic'
            do @connections.toggleMicro

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
            @loadModules modules, cb

    # Load the Modules given in parameter recursively.
    # Parameter's type must be an array.
    loadModules         : (modules, cb) ->
        if modules.length != 0
            mod = do modules.shift
            @loadScript mod, modules, cb
        else
            do cb

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
        room = new Room window.modules
