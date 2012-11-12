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

Path    = require 'path'

Logger  = require './core/logger'

class _Config
    constructor : () ->
        console.log "construction"

        @Dirs    =
            Static  : 'public'
        
        @Paths   =
            Webroot : Path.join __dirname, '..'
        @Paths.Approot          = Path.join @Paths.Webroot, '..'
        @Paths.Logs             = Path.join @Paths.Approot, 'log'
        @Paths.Config           = Path.join @Paths.Approot, 'etc'
        @Paths.Views            = Path.join @Paths.Webroot, @Dirs.Static, 'core', 'tpl'
        @Paths.Services         = Path.join __dirname, 'services'
        @Paths.StaticServices   = Path.join __dirname, @Dirs.Static, 'services'
        
        @SERVER_PORT    = 4242

        @LOGLEVEL       = Logger.DEBUG

        @LOGONSTDOUT    = true

        @PATH_ROUTES    = [ 'room' ]


class Config
    @_instance  = undefined
    @get        : () ->
        @_instance  ?= new _Config

c   = do Config.get
for key of c
    exports[key]    = c[key]
