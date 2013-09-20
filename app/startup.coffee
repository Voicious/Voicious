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

{spawn} = require 'child_process'
Path    = require 'path'
Fs      = require 'fs'
Moment  = require 'moment'
Config  = require './common/config'

WriteLog  = (fd, data) =>
    if data?
        toLog = '[' + ((do Moment).format 'YYYY MMM DD hh:mm:ssa') + '] ' + data
        Fs.writeSync fd, (new Buffer toLog), 0, toLog.length

processes = []

if not Fs.existsSync Config.Paths.Logs
    Fs.mkdirSync Config.Paths.Logs, '0755'

require './core/voicious'

if Config.Websocket.Enabled
    require './ws/websocket'

if Config.Peerjs.Enabled
	require './pjs/peerjs'
