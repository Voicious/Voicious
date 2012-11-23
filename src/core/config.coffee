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

Logger  = require './logger'

class _Config
    loadDatabaseConfig  : (dbConfig)    ->
        if dbConfig is undefined
            throw new (Error "A database must be configured in etc/config.json !")

        @Database   =
            connector   : dbConfig.connector
            user        : dbConfig.user
            password    : dbConfig.password
            database    : dbConfig.database

        if not { "mongodb" : "" , "sqlite3" : "" }.hasOwnProperty @Database.connector
            throw new (Error "Your database connector is not supported (yet) !")

        if @Database.connector is "mongodb" and (@Database.user is undefined or @Database.password is undefined or @Database.database is undefined)
            throw new (Error "When using MongoDB, you must specify a user, a password and a database name !")

        if @Database.connector is "sqlite3" and @Database.database is undefined
            throw new (Error "When using SQLite3, you must specify a database name !")

    loadConfigJSON      : ()            ->
        fileToOpen  = 'config'
        if process.env.NODE_ENV
            fileToOpen  += '.' + process.env.NODE_ENV
        tmpJSON     = require (Path.join @Paths.Config, fileToOpen + ".json")

        @Port       = tmpJSON.port

        @Logger     =
            Level   : Logger.getLevelFromString tmpJSON.logger.level
            Stdout  : tmpJSON.logger.stdout

        @loadDatabaseConfig (tmpJSON.database || undefined)

        @Acl        = tmpJSON.acl

        @Roles      = tmpJSON.roles

    constructor         : ()            ->
        @Dirs    =
            Static  : 'public'

        @Paths   =
            Webroot : Path.join __dirname, '..', '..'
        @Paths.Approot          = Path.join @Paths.Webroot, '..'
        @Paths.Logs             = Path.join @Paths.Approot, 'log'
        @Paths.Config           = Path.join @Paths.Approot, 'etc'
        @Paths.Views            = Path.join @Paths.Webroot, @Dirs.Static, 'core', 'tpl'
        @Paths.Services         = Path.join __dirname, '..', 'services'
        @Paths.StaticServices   = Path.join __dirname, '..', '..', @Dirs.Static, 'services'
        
        @PATH_ROUTES    = [ 'room' ]

        do @loadConfigJSON


class Config
    @_instance  = undefined
    @get        : () ->
        @_instance  ?= new _Config

c   = do Config.get
for key of c
    exports[key]    = c[key]
