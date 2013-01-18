###

Copyright (c) 2011-2012  Voicious

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
Config  = require './common/config'

processes = []

if Config.Voicious.Enabled
    voicious = spawn 'node', [(Path.join Config.Paths.Approot, 'lib', 'core', 'voicious.js')]
    voicious.stdout.on 'data', (data) =>
        process.stdout.write "#{data}"
    voicious.stderr.on 'data', (data) =>
        process.stderr.write "#{data}"
    processes.push voicious

if Config.Restapi.Enabled
    rest     = spawn 'node', [(Path.join Config.Paths.Approot, 'lib', 'rest', 'api.js')]
    rest.stdout.on 'data', (data) =>
        process.stdout.write "#{data}"
    rest.stderr.on 'data', (data) =>
        process.stderr.write "#{data}"
    processes.push voicious
    
if Config.Websocket.Enabled
    voicious = spawn 'node', [(Path.join Config.Paths.Approot, 'lib', 'ws', 'websocket.js')]
    voicious.stdout.on 'data', (data) =>
        process.stdout.write "#{data}"
    voicious.stderr.on 'data', (data) =>
        process.stderr.write "#{data}"
    processes.push voicious

process.on 'SIGINT', () =>
    for proc in processes
        proc.kill 'SIGINT'
