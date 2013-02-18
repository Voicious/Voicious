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
    constructor     : () ->
        @jqMessageBox = ($ '#tcMessagesContainer')
        $('#tcSendMessageBtn').click () =>
            message = do $('#tcMessageInput').val
            @sendMessage message

    update          : (message) =>
        @addMessage message
    
    sendMessage     : (message) =>
        event = EventManager.getEvent "sendTextMessage"
        if event?
            event ['message', null, message]
            @addMessage message

    addMessage      : (message) =>
        elem = ($ '<div>', {class : 'msgBox'})
        #authorLine = ($ ('<p>')).append ($ '<span>', {class : 'author'}).html author
        #authorLine.append ($ '<span>', {class : 'time'}).html time
        #elem.append authorLine
        elem.append ($ '<p>', {class : 'message'}).html message
        @jqMessageBox.append elem

TC = TextChat

if window?
    window.TextChat     = TC
if  explorts?
    exports.TextChat    = TC
