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

sourceDir   = "."
destDir     = "."
sourceFiles = ["config", "errorHandler", "render", "router", "server", "start"]

compile     = (file) ->
    sourceFile  = sourceDir + "/" + file + ".coffee"
    destFile    = destDir   + "/" + file + ".js"
    console.log "Processing...  [" + sourceFile + "] -> [" + destFile + "]" 
    exec 'coffee --compile --output ' + destDir + ' ' + sourceFile, (err, stdout, stderr) ->
        throw err if err 
        console.log stdout + stderr

remove      = (file) ->
    console.log "Removing... [" + file + ".js]"
    exec 'rm -f ' + file + '.js', (err, stdout, stderr) ->
        throw err if err

task 'build', 'Build project', ->
    compile file for file in sourceFiles
    console.log "Done."

task 'clean', 'Remove all Javascript files', ->
    remove file for file in sourceFiles
    console.log "Done."
