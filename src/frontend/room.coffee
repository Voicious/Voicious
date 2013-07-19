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
        @rid         = (window.location.pathname.split '/')[2]
        @uid         = window.Voicious.currentUser.uid
        @moduleArray = new Array

        do @setPage
        if window.ws? and window.ws.Host? and window.ws.Port?
            @connections    = new Voicious.Connections @emitter, @uid, @rid, { host : window.ws.Host, port : window.ws.Port }
            @commandManager = new CommandManager @emitter
            @buttonManager  = new Voicious.ButtonManager @emitter
            @loadModules modules, () =>
                do @connections.dance
        $('#reportBug').click @bugReport

    activateCam         : () =>
        do @connections.toggleCamera
        activeStream = @connections.userMedia
        if activeStream['video'] is on and activeStream['audio'] is off or
        activeStream['video'] is off and activeStream['audio'] is on
            ($ '#mic').trigger 'click'
        else
            @emitter.trigger 'activable.lock', @connections.userMedia
            do ($ '#feeds > li:first > video:first').remove
            do @connections.modifyStream

    activateMic         : () =>
        do @connections.toggleMicro
        @emitter.trigger 'activable.lock', @connections.userMedia
        do ($ '#feeds > li:first > video:first').remove
        do @connections.modifyStream

     refreshOnOff : (btn, val) =>
        label = btn.find 'span'
        icon  = btn.find 'i'
        text = (do label.text)
        oldVal = if text is 'OFF' then off else on
        if oldVal isnt val
            btn.toggleClass 'green red'
            icon.toggleClass 'dark-grey white'
            label.text (if (do label.text) is 'OFF' then 'ON' else 'OFF')

    setOnOff            : () =>
        ($ '#cam').click @activateCam
        ($ '#mic').click @activateMic
        @emitter.on 'activable.lock', (event, data) =>
             if data['video'] is off and data['audio'] is off
                @refreshOnOff ($ '#cam'), data['video']
                @refreshOnOff ($ '#mic'), data['audio']
                return
             ($ 'button.activable').each (idx, elem) ->
                jqElem = ($ elem)
                jqElem.attr 'disabled', on
                (jqElem.children 'span').toggleClass 'disable'
        @emitter.on 'activable.unlock', (event, data) =>
            ($ 'button.activable').each (idx, elem) =>
                jqElem = ($ elem)
                jqElem.attr 'disabled', off
                (jqElem.children 'span').toggleClass 'disable'
                if data isnt undefined
                    @refreshOnOff ($ '#cam'), data['video']
                    @refreshOnOff ($ '#mic'), data['audio']

    setClipboard        : () ->
        jqElem = $ '#clipboardLink'
        jqElem.attr 'data-clipboard-text', window.location
        clip = new ZeroClipboard jqElem[0], { moviePath: "/public/swf/vendor/ZeroClipboard.swf", hoverClass: "clipHover" }
        clip.on 'complete', () ->
            ($ '.notification-wrapper').fadeIn(600).delay(3000).fadeOut(1000)

    setPage             : () ->
        $('#sidebarAcc').accordion { active: false, collapsible: true, heightStyle: 'content', icons: off }
        $('.headerAcc').click () ->
            elem = ($ this)
            elem.toggleClass 'down'
            jqSiblinsA = elem.siblings 'a'
            jqSiblinsA.removeClass 'down'
        do @setOnOff
        do @setClipboard

    # Get the javascript for the new module given in parameter
    # and call getModuleHTML.
    loadScript          : (moduleName, modules, cb) ->
        $.ajax(
            type    : 'GET'
            url     : "/public/js/#{moduleName}.js"
            dataType: 'script'
        ).done (data) =>
            eval data
            module    = do (moduleName.charAt 0).toUpperCase + moduleName.slice 1
            theModule = (new window[module] @emitter)
            @emitter.on 'module.initialize', theModule.initialize
            @moduleArray.push theModule
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
