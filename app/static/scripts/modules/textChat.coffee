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

        #Define the Markdown interpretor
        @markdown     = new Showdown.converter { extensions : ['voicious'] }

        #Define accessor for DOM elements
        @content = ($ '#textChat')
        @content.messages = @content.find '#chatContent > ul'
        @content.form = @content.find 'form'
        @content.form.textarea = @content.form.find 'textarea'

        #Launch jScrollpane
        @scrollPane   = @content.messages.jScrollPane horizontalDragMaxWidth : 0
        @scrollPane   = @content.messages.data 'jsp'
        ($ window).resize () =>
            do @scrollPane.reinitialise

        #Define what's going on when and how the form is submitted
        @content.form.textarea.on 'keypress', (event) =>
            if event.keyCode is 13 and not event.shiftKey
                do event.preventDefault
                @content.form.trigger 'submit'
        @content.form.submit @submit

        #Initialize the message list and tis watcher
        (@messages = []).watch 'length', @update

        #Define chat's own commands
        @emitter.trigger 'cmd.register',
            name : 'me'
            callback : @me
            infos : "usage: /me action"

        #Define event bindings
        @emitter.on 'chat.message', @newMessage

        @emitter.on 'peer.create', (event, data) =>
           @emitter.trigger 'chat.message', { text : "#{data.name}" + $.t("app.textChat.EnterRoom") }
        @emitter.on 'peer.remove', (event, data) =>
            @emitter.trigger 'chat.message', { text : "#{data.name}" + $.t("app.textChat.LeaveRoom") + " (#{data.reason})" }

    submit : (event) =>
        #Do not send the form
        do event.preventDefault
        #Translating line break to HTML <br />
        message = (do @content.form.textarea.val).replace /\n/g, '<br />'
        @content.form.textarea.val ''
        # We check if it's a command or a message
        command = message.match(/^\/([a-zA-Z ]+)/)
        if command?
            @sendCommand command
        else
            @sendMessage message
        #Do not send the form
        no

    # Update the text chat with a new message.
    update          : () =>
        #Empty the message list
        container = (do @scrollPane.getContentPane)
        do container.empty

        prevMessage = undefined
        #Loop through all messages
        @messages.map (message) =>
            #Humanize the timestamp
            formatedTime = (do (new Date message.time).toTimeString).substr 0, 5
            #Group message sent by a user
            if prevMessage? and prevMessage.message.from is message.from isnt undefined and message.time - prevMessage.message.time < 3000
                prevMessage.message = message
                (($ prevMessage.html[2]).find '.chatmessage').append message.text
            else
                html = undefined
                #If message.from is not defined, thew it is a server message
                if message.from?
                    html = """
                        <div class='chatmetadata'>
                            <span class='fontlightblue'>#{message.from}</span>
                            <span class='time'> at #{formatedTime}</span>
                        </div>
                        <div class='chatmessage'>#{message.text}</div>
                    """
                else
                    html = """
                        <div class='blueduckturquoise #{if not message.me then "italic"}'>
                            #{message.text}
                            <span class='time'> at #{formatedTime}</span>
                        </div>
                    """
                prevMessage =
                    html : ($ """
                        <div class='tcSeparator'></div>
                        <li>
                            #{html}
                        </li>
                    """).appendTo container
                    message : message

        #Reinitialize the scrollPane and scroll to its bottom
        do @scrollPane.reinitialise
        @scrollPane.scrollToPercentY 100, no

    # Send the command to the command Manager
    sendCommand     : (command) =>
        command =
            cmd : command[1]
            from : window.Voicious.currentUser.name
        @emitter.trigger 'cmd.cmd', command

    # Send the new message to the guests.
    sendMessage     : (message) =>
        if message? and message isnt ""
            message =
                text : @markdown.makeHtml message
                from : window.Voicious.currentUser.name
            @emitter.trigger 'message.sendtoall', message
            @emitter.trigger 'chat.message', message

    newMessage : (event, message) =>
        @emitter.trigger 'notif.audio', { name : "chat.message" }
        # Remove unwanted server data
        message = message.message if message.message?
        #Append a timestamp to the object
        message.time = do (new Date).getTime
        #Push the object into the watched array
        @messages.push message

    me : (user, data) =>
        message = undefined
        if data[1]?
            action = (data.slice 1).join " "
            text = "#{user} #{action}"
            message = { type : 'chat.me',  params : { text : text } }
            @emitter.trigger 'message.sendtoall', message
            message = {text : text, me : yes}
        else
            message = { text : "me: usage: /me action" }
        @newMessage null, message

    onMe                : (data) =>
        @emitter.trigger 'chat.me', { text : data.text }

if window?
    window.TextChat     = TextChat
