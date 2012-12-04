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
path        = require 'path'

sourceDir   = "src"
destDir     = "www/lib"
sourceFiles = [
    "start"
]

coreDir     = "core"
coreFiles   = [
    "config"
    "database"
    "errors"
    "populateDB"
    "voicious"
]

servicesDir = "services"
services    = [
    "api"
    "room"
    "service"
    "session"
    "user"
]


compile     = (file, subDir = '.')              ->
    sourceFile  = path.join __dirname, sourceDir, file + ".coffee"
    destFile    = path.join __dirname, destDir, file + ".js"
    console.log "Processing...  [" + (path.join sourceDir, file + ".coffee") + "] -> [" + (path.join destDir, file + ".js") + "]"
    exec 'coffee --compile --output ' + (path.join destDir, subDir) + ' ' + sourceFile, (err, stdout, stderr) ->
        throw err if err

remove      = (file)                            ->
    console.log "Removing... [" + (path.join destDir, file + ".js") + "]"
    exec 'rm -f ' + (path.join __dirname, destDir, file + ".js"), (err, stdout, stderr) ->

task 'build', 'Build project',                  ->
    exec 'mkdir ' + (path.join __dirname, destDir) if not fs.exists (path.join __dirname, destDir)
    compile file for file in sourceFiles
    exec 'mkdir ' + (path.join __dirname, destDir, coreDir) if not fs.exists (path.join __dirname, destDir, coreDir)
    compile (path.join coreDir, file), coreDir for file in coreFiles
    for service in services
        compile (path.join servicesDir, service), servicesDir
    console.log "Done."


task 'clean', 'Remove all Javascript files',    ->
    remove file for file in sourceFiles
    remove (path.join coreDir, file) for file in coreFiles
    for service in services
        remove (path.join servicesDir, service, service)
        exec 'rmdir ' + (path.join __dirname, destDir, servicesDir, service)
    exec 'rmdir ' + (path.join __dirname, destDir, coreDir)
    exec 'rmdir ' + (path.join __dirname, destDir, servicesDir)
    console.log "Done."
