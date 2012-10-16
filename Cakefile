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

{exec}      = require 'child_process'
fs          = require 'fs'

sourceDir   = "."
destDir     = "."
sourceFiles = [
    "config",
    "errorHandler",
    "logger",
    "render",
    "routeHandler",
    "router",
    "server",
    "start"
]

compile     = (file) ->
    sourceFile  = __dirname + "/" + sourceDir + "/" + file + ".coffee"
    destFile    = __dirname + "/" + destDir + "/" + file + ".js"
    console.log "Processing...  [" + sourceDir + "/" + file + ".coffee] -> [" + destDir + "/" + file + ".js]" 
    exec 'coffee --compile --output ' + destDir + ' ' + sourceFile, (err, stdout, stderr) ->
        throw err if err

remove      = (file) ->
    console.log "Removing... [" + destDir + "/" + file + ".js]"
    exec 'rm -f ' + __dirname + "/" + destDir + "/" + file + ".js", (err, stdout, stderr) ->
        throw err if err

task 'build', 'Build project', ->
    exec 'mkdir ' + __dirname + '/' + destDir if not fs.exists __dirname + '/' + destDir
    compile file for file in sourceFiles
    console.log "Done."

task 'clean', 'Remove all Javascript files', ->
    remove file for file in sourceFiles
    console.log "Done."
