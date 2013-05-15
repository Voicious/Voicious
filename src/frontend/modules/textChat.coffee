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
        @jqForm       = ($ '#chatform > form')
        @jqMessageBox = ($ '#chatcontent > ul')
        @jqInput      = @jqForm.children 'input[type=\'text\']'

        @scrollPane   = do @jqMessageBox.jScrollPane
        @scrollPane   = @jqMessageBox.data 'jsp'

        @jqForm.submit (event) =>
            do event.preventDefault
            message = do @jqInput.val
            @jqInput.val ''
            @sendMessage message

        $(window).resize () =>
            return
            do @scrollPane.reinitialise

        @emitter.on 'chat.message', (event, data) =>
            @addMessage data.message


    appendHTML      : () ->
        html = ($ '<div class="span3 darkgray module fill-height" id="textChat">
                <div class ="module-wrapper">
                    <div id="chatcontent">
                        <ul></ul>
                    </div>
                    <div id="chatform">
                        <form>
                            <span>Press RETURN to post</span>
                            <input type="text">
                    </div>
                </div>
            </div>'
        )
        html.appendTo "#middle-row"

    # Update the text chat with a new message.
    update          : (message) =>
        @addMessage message
        $(window).trigger "newMessage"

    # Send the new message to the guests.
    sendMessage     : (message) =>
        if message? and message isnt ""
            message =
                text : message
                from : window.CurrentUser
            @emitter.trigger 'message.sendtoall', message
            @addMessage message

    # Create a new message element and append it to @jqMessageBox
    newMessageElem : (message) =>
        d             = new Date
        jqNewMetadata = ($ '<div>', { class : 'chatmetadata' })
        jqNewAuthor   = ($ '<span>', { class : 'fontlightblue', rel : do d.getTime }).text message.from
        jqNewTime     = ($ '<span>', { class : 'time' }).text ' at ' + ((do d.toTimeString).substr 0, 5)
        (jqNewMetadata.append jqNewAuthor).append jqNewTime
        jqNewMessage  = ($ '<div>', { class : 'chatmessage' }).html message.text
        (do @scrollPane.getContentPane).append (($ '<li>').append jqNewMetadata).append jqNewMessage

    # Add a new message to the text chat window.
    addMessage      : (message) =>
        message.text  = @markdown.makeHtml message.text
        jqLastMessage = do (@jqMessageBox.find 'li').last
        if jqLastMessage[0]?
            d          = new Date
            lastAuthor = do ((jqLastMessage.children '.chatmetadata').children 'span').first
            diffTime   = do d.getTime - lastAuthor.attr 'rel'
            if do lastAuthor.text is message.from and diffTime < 30000
                (jqLastMessage.children '.chatmessage').append ($ '<br>')
                (jqLastMessage.children '.chatmessage').append message.text
                lastAuthor.attr 'rel', do d.getTime
            else
                @newMessageElem message
        else
            @newMessageElem message
        do @scrollPane.reinitialise
        @scrollPane.scrollToPercentY 100, no

if window?
    window.TextChat     = TextChat
