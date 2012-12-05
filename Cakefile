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
Path        = require 'path'

toCompile   = [
    {
        sourceDir   : 'src'
        destDir     : (Path.join 'www', 'lib')
        files       : [ 'start' ]
    }
    {
        sourceDir   : (Path.join 'src', 'core')
        destDir     : (Path.join 'www', 'lib', 'core')
        files       : [
            'config'
            'database'
            'errors'
            'populateDB'
            'voicious'
        ]
    }
    {
        sourceDir   : (Path.join 'src', 'services')
        destDir     : (Path.join 'www', 'lib', 'services')
        files       : [
            'api'
            'room'
            'service'
            'session'
            'user'
        ]
    }
    {
        sourceDir   : (Path.join 'src', 'frontend')
        destDir     : (Path.join 'www', 'public', 'js')
        files       : [
            "global"
            "home"
        ]
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
