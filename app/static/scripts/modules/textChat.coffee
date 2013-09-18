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

do () ->
    showdownExt = (converter) ->
        [
            {
                type   : 'lang'
                filter : (text) ->
                    text.replace /<?(http|https|ftp)\:\/\/([^\s]+)>?/, "[$1://$2]($1://$2)"
            }
            {
                type   : 'output'
                filter : (source) ->
                    source.replace /<a href="(.+)">(.+)<\/a>/, '<a href="$1" target="_blank">$2</a>'
            }
        ]
    if window? and window.Showdown and window.Showdown.extensions
        window.Showdown.extensions.voicious = showdownExt

class TextChat extends Module
    # Init the text chat window and the callbacks in the event manager.
    constructor     : (emitter) ->
        super emitter

        @markdown     = new Showdown.converter { extensions : ['voicious'] }
        @content = ($ '#textChat')
        @content.messages = @content.find '#chatContent > ul'
        @content.form = @content.find 'form'
        @content.form.textarea = @content.form.find 'textarea'

        @scrollPane   = @content.messages.jScrollPane horizontalDragMaxWidth : 0
        @scrollPane   = @content.messages.data 'jsp'

        @content.form.textarea.on 'keypress', (event) =>
            if event.keyCode is 13 and not event.shiftKey
                do event.preventDefault
                @content.form.trigger 'submit'

        @content.form.submit @submit

        (@messages = []).watch 'length', @update

        ($ window).resize () =>
            do @scrollPane.reinitialise

        @emitter.trigger 'cmd.register',
            name : 'me'
            callback : @me

        ['chat.message', 'chat.error', 'chat.info', 'chat.me'].map (eType) =>
            @emitter.on eType, @newMessage

        @emitter.on 'peer.create', (event, data) =>
            @emitter.trigger 'chat.error', { text : "#{data.name} arrives in the room." }
        @emitter.on 'peer.remove', (event, data) =>
            @emitter.trigger 'chat.error', { text : "#{data.name} leaves the room. (#{data.reason})" }

    submit : (event) =>
        do event.preventDefault
        message = (do @content.form.textarea.val).replace /\n/g, '<br />'
        @content.form.textarea.val ''
        # We check if it's a command or a message
        command = message.match(/^\/([a-zA-Z ]+)/)
        if command?
            @sendCommand command
        else
            @sendMessage message
        no

    # Update the text chat with a new message.
    update          : () =>
        container = (do @scrollPane.getContentPane)
        do container.empty
        prevMessage = undefined
        @messages.map (message) =>
            if prevMessage? and prevMessage.message.from is message.from and message.time - prevMessage.message.time < 3000
                prevMessage.message = message
                (($ prevMessage.html[2]).find '.chatmessage').append message.text
            else
                elem = ($ """
                    <div class='tcSeparator'></div>
                    <li>
                        <div class='chatmetadata'>
                            <span class='fontlightblue'>#{message.from}</span>
                            <span class='time'>
                                 at #{((do (new Date message.time).toTimeString).substr 0, 5)}
                            </span>
                        </div>
                        <div class='chatmessage'>#{message.text}</div>
                    </li>
                """).appendTo container
                prevMessage =
                    html : elem
                    message : message
        do @scrollPane.reinitialise
        @scrollPane.scrollToPercentY 100, no

    # Send the command to the command Manager
    sendCommand     : (command) =>
        command =
            cmd : command[1]
            from : window.Voicious.currentUser.name
        @emitter.trigger 'chat.cmd', command

    # Send the new message to the guests.
    sendMessage     : (message) =>
        if message? and message isnt ""
            message =
                text : @markdown.makeHtml message
                from : window.Voicious.currentUser.name
            @emitter.trigger 'message.sendtoall', message
            @emitter.trigger 'chat.message', message

    newMessage : (event, message) =>
        message.time = do (new Date).getTime
        @messages.push message

if window?
    window.TextChat     = TextChat
