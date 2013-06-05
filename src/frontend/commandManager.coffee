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
        @emitter.on 'chat.cmd', (event, data) =>
            @parseCmd data

    # Parse the command and call the right function.
    parseCmd        : (command) =>
        cmd = command.cmd.split(' ')
        user = command.from
        # It will be better with a switch later
        if cmd[0] is "kick" and cmd[1]?
            @kick cmd[1], ""
    
    # Kick command implementation
    kick            : (user, reason) =>
        message = { type : 'cmd.kick', to : user, params : { message : reason } }
        @emitter.trigger 'message.sendToOneName', message
        
    
if window?
    window.CommandManager   = CommandManager
