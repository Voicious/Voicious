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

path = require 'path'

module.exports = (grunt) ->

    grunt.initConfig
        pkg    : grunt.file.readJSON 'package.json'
        coffee :
            glob_to_multiple :
                expand : yes
                cwd    : 'src'
                src    : [ '**/*.coffee' ]
                dest   : 'lib'
                ext    : '.js'
                rename : (dest, matchedSrcPath, options) ->
                    r = /^(frontend)\/.*(.js)$/
                    if r.test matchedSrcPath
                        fileName = matchedSrcPath.split path.sep
                        fileName = fileName[fileName.length - 1]
                        path.join 'www', 'public', 'js', fileName
                    else
                        path.join dest, matchedSrcPath
        docco  :
            src     : [ 'src/**/*.coffee' ]
            options :
                output : 'docs/'
        clean  : [ 'docs/', 'lib/' ]

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-docco'
    grunt.loadNpmTasks 'grunt-contrib-clean'

    grunt.registerTask 'build', [ 'coffee' ]
    grunt.registerTask 'all', [ 'build', 'docco' ]
    grunt.registerTask 're', [ 'clean', 'all' ]

    grunt.registerTask 'default', [ 'build' ]
