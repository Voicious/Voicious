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
        @emitter.on 'cmd.cmd', (event, data) =>
            @parseCmd data
        @emitter.on 'cmd.register', (event, data) =>
            @register data
        @emitter.on 'cmd.remove', (event, data) =>
            @remove data
        option = { resGetPath: '/locales/__lng__/__ns__.json', useLocalStorage: true , useDataAttrOptions:true}
        $.i18n.init option


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
            @emitter.trigger 'chat.message', { text: cmd[0] + ": command not found." }

    # Display the available commands
    help            : () =>
        message = "Commands list:<br/>"
        for name, cb of @commands
            message += "/" + name
            if @infos[name]?
                message += ": " + @infos[name]
            message += "<br/>"
        @emitter.trigger 'chat.message', { text : message }

if window?
    window.CommandManager   = CommandManager
