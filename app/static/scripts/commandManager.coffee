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
        @commands = {'help' : @help }
        @infos = {'help' : "display this help" }
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

    # Register a command
    register        : (data) =>
        @commands[data.name] = data.callback
        if data.infos?
            @infos[data.name] = data.infos
    
    # Remove a command from the list
    remove          : (data) =>
        @commands[data] = null
        delete @commands[data]
        @infos[data] = null
        delete @infos[data]

    # Parse the command and call the right function.
    parseCmd        : (command) =>
        cmd = do command.cmd.trim
        cmd = cmd.split ' '
        user = String command.from
        if @commands[cmd[0]]?
            @commands[cmd[0]] user, cmd
        else
            @emitter.trigger 'chat.error', { text: cmd[0] + ": command not found." }

    onKick          : (data) =>
        #document.cookie = 'connect.sid=; expires=Thu, 01-Jan-70 00:00:01 GMT;'
        text    = "#{window.Voicious.currentUser.name} has been kicked out! (#{data.message})"
        message = { type : 'chat.error', params : { text : text } }
        @emitter.trigger 'message.sendtoall', message
        window.location.replace '/'
    
    onMe            : (data) =>
        @emitter.trigger 'chat.me', { text : data.text }

    help            : () =>
        message = "Commands list:<br/>"
        for name, cb of @commands
            message += "/" + name 
            if @infos[name]?
                message += ": " + @infos[name]
            message += "<br/>"
        @emitter.trigger 'chat.info', { text : message }

if window?
    window.CommandManager   = CommandManager
