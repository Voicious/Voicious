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

{spawn, exec}   = require 'child_process'
Path            = require 'path'
Fs              = require 'fs'

toCompile   = [
    {
        sourceDir   : 'src'
        destDir     : 'lib'
        files       : [ 'startup' ]
    }
    {
        sourceDir   : (Path.join 'src', 'common')
        destDir     : (Path.join 'lib', 'common')
        files       : [ 'config' ]
    }
    {
        sourceDir   : (Path.join 'src', 'core')
        destDir     : (Path.join 'lib', 'core')
        files       : [ 'errors', 'populateDB', 'room', 'session', 'user', 'voicious', 'token' ]
    }
    {
        sourceDir   : (Path.join 'src', 'rest')
        destDir     : (Path.join 'lib', 'rest')
        files       : [ 'api' ]
    }
    {
        sourceDir   : (Path.join 'src', 'models')
        destDir     : (Path.join 'lib', 'models')
        files       : [ 'user' , 'room', 'token' ]
    }
    {
        sourceDir   : (Path.join 'src', 'frontend')
        destDir     : (Path.join 'www', 'public', 'js')
        files       : [ 'global', 'home', 'mediaStream' ]
    }
    {
        sourceDir   : (Path.join 'src', 'ws')
        destDir     : (Path.join 'lib', 'ws')
        files       : [ 'websocket' ]
    }
]

compile     = (sourceDir, destDir, file) ->
    sourceFile  = Path.join __dirname, sourceDir, file + ".coffee"
    destFile    = Path.join __dirname, destDir, file + ".js"
    console.log "Processing...  [#{sourceFile}] -> [#{destFile}]"
    exec "coffee --compile --output #{destDir} #{sourceFile}", (err, stdout, stderr) ->
        throw err if err

task 'build', 'Build project', ->
    for elem in toCompile
        exec "mkdir #{Path.join __dirname, elem.destDir}"
        for file in elem.files
            compile elem.sourceDir, elem.destDir, file
    console.log "Done."

task 'clean', 'Delete all compile files', ->
    for elem in toCompile
        for file in elem.files
            console.log "Deleting... [#{Path.join __dirname, elem.destDir, file}.js]"
            exec "rm #{Path.join __dirname, elem.destDir, file}.js"
        exec "rmdir #{Path.join __dirname, elem.destDir}"
    console.log "Done."

task 'doc', 'Build documentation', ->
    allDirs = []
    for elem in toCompile
        allDirs.push (Path.join elem.sourceDir, '*.coffee')
    docco   = spawn 'docco', allDirs
    docco.stderr.on 'data', (data)  =>
        process.stderr.write (do data.toString)
    docco.stdout.on 'data', (data)  =>
        process.stdout.write (do data.toString)
    docco.on 'exit', (code)         =>
        console.log "Done."
