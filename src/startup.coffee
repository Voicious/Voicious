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

voiciousAccessLog = Fs.openSync (Path.join Config.Paths.Logs, 'voicious.access.log'), 'a+'
voiciousErrorLog  = Fs.openSync (Path.join Config.Paths.Logs, 'voicious.error.log'), 'a+'
voicious          = spawn 'node', [(Path.join Config.Paths.Root, 'lib', 'core', 'voicious.js')]
voicious.stdout.on 'data', (data) =>
    process.stdout.write "#{data}"
    WriteLog voiciousAccessLog, data
voicious.stderr.on 'data', (data) =>
    process.stderr.write "#{data}"
    WriteLog voiciousErrorLog, data
processes.push voicious

if Config.Websocket.Enabled
    wsAccessLog = Fs.openSync (Path.join Config.Paths.Logs, 'ws.access.log'), 'a+'
    wsErrorLog  = Fs.openSync (Path.join Config.Paths.Logs, 'ws.error.log'), 'a+'
    ws          = spawn 'node', [(Path.join Config.Paths.Root, 'lib', 'ws', 'websocket.js')]
    ws.stdout.on 'data', (data) =>
        process.stdout.write "#{data}"
        WriteLog wsAccessLog, data
    ws.stderr.on 'data', (data) =>
        process.stderr.write "#{data}"
        WriteLog wsErrorLog, data
    processes.push ws

process.on 'SIGINT', () =>
    for proc in processes
        proc.kill 'SIGINT'
