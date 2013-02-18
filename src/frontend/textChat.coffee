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

class   TextChat
    constructor     : (NetworkManager) ->
        @jqForm       = ($ 'form#chatForm')
        @jqMessageBox = ($ '#tcMessagesContainer')
        @jqInput      = ($ 'input#tcMessageInput')
        @jqForm.submit (event) =>
            do event.preventDefault
            message = do @jqInput.val
            @jqInput.val ''
            @sendMessage message

        EventManager.addEvent "sendTextMessage", (message) =>
            NetworkManager.sendToAll message
        EventManager.addEvent "receiveTextMessage", (message) =>
            @update message

    update          : (message) =>
        @addMessage message
    
    sendMessage     : (message) =>
        message =
            text : message
            from : window.CurrentUser
        event   = EventManager.getEvent "sendTextMessage"
        if event?
            event ['message', null, message]
            @addMessage message

    addMessage      : (message) =>
        elem = ($ '<div>', {class : 'msgBox'})
        authorLine = ($ ('<p>')).append ($ '<span>', {class : 'author'}).html message.from
        #authorLine.append ($ '<span>', {class : 'time'}).html 
        elem.append authorLine
        elem.append ($ '<p>', {class : 'message'}).html message.text
        @jqMessageBox.append elem

TC = TextChat

if window?
    window.TextChat     = TC
