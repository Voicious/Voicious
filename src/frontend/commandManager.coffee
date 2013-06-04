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
    constructor     : (emitter) ->
        super emitter
        
        @emitter.on 'chat.cmd', (event, data) =>
            @parseCmd data.command

    # Parse the command and call the right function.
    parseCmd        : (command) =>
        cmd = command[1].split(' ')
        user = command[2]
        console.log cmd
    
    # Kick command implementation
    kick            : (op, user) =>
        console.log op + ' kicks ' + user
    

if window?
    window.CommandManager   = new CommandManager
