###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###


class CommandManager
    # Initialize the Command Manager and set the callbacks for the Event Manager.
    constructor     : (@emitter) ->
        @commands = { }
        @emitter.on 'chat.cmd', (event, data) =>
            @parseCmd data
        @emitter.on 'cmd.kick', (event, data) =>
            @onKick data
        @emitter.on 'cmd.me', (event, data) =>
            @onMe data
        @emitter.on 'cmd.register', (event, data) =>
            @register data
        @emitter.on 'cmd.remove', (event, data) =>
            @remove data

    # Parse the command and call the right function.
    parseCmd        : (command) =>
        cmd = command.cmd.split(' ')
        user = String command.from
        if @commands[cmd[0]]?
            @commands[cmd[0]] cmd
        else
            @emitter.trigger 'chat.error', { text: cmd[0] + ": command not found." }
        switch  cmd[0]
            when 'me' then do () =>
                if cmd[1]?
                    action = (cmd.slice 1).join " "
                    @me user, action
                else
                    @emitter.trigger 'char.error', { text: "me: usage: /me [action]"}
            when 'quit' then do () =>
                message = ""
                if cmd[1]?
                    message = (cmd.slice 1).join " "
                @quit message
            when 'help' then do @help
            else
                @emitter.trigger 'chat.error', { text: cmd[0] + ": command not found." }

    onKick          : (data) =>
        #document.cookie = 'connect.sid=; expires=Thu, 01-Jan-70 00:00:01 GMT;'
        text    = "#{window.Voicious.currentUser.name} has been kicked out! (#{data.message})"
        message = { type : 'chat.error', params : { text : text } }
        @emitter.trigger 'message.sendtoall', message
        window.location.replace '/'

    me              : (user, data) =>
        text = "#{user} #{data}"
        message = { type : 'cmd.me',  params : { text : text } }
        # will have to remplace by type 'chat.me'
        @emitter.trigger 'message.sendtoall', message
        @emitter.trigger 'chat.me', { text : text }
    
    onMe            : (data) =>
        # will have to remplace by type 'chat.me'
        @emitter.trigger 'chat.me', { text : data.text }
    
    quit            : (message) =>
        text = "#{window.Voicious.currentUser.name} has left the room. (#{message})"
        message = { type : 'chat.error', params : { text : text } }
        # duplicate with the first login/logout messages, so it is desactivated for the moment.
        # @emitter.trigger 'message.sendtoall', message
        window.location.replace '/'
    
    help            : () =>
        message = { text : "Commands list:<br/>
                    /help<br/>
                    /kick user [reason]<br/>
                    /me [action]<br/>
                    /quit [message]" }
        @emitter.trigger 'chat.info', message
    
    register        : (data) =>
        @commands[data.name] = data.callback
    
    remove          : (data) =>
        @commands[data] = null
        delete @commands[data]
        
    
if window?
    window.CommandManager   = CommandManager
