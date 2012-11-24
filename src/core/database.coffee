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

Schema  = (require 'jugglingdb').Schema
Config  = require './config'

class _Database
    constructor: () ->
        console.log "INSTANCIATE DB"
        @Databases = undefined

    connect: () ->
        @Databases  = new Schema Config.Database.connector, Config.Database

    createTable: (tableName, schema) ->
        @Databases[tableName] = @Databases.define tableName, schema

    flushTable: (callback) ->
        @Databases.automigrate callback

    insert: (tableName, queryObj, callback) ->
        @Databases[tableName].create queryObj, callback

    get: (tableName, query, callback)  ->
        @Databases[tableName].all query, callback

    close: () ->
        @Databases?.disconnect()

class Database
    @_instance = undefined

    @get : () ->
        @_instance ?= new _Database

d = do Database.get
for key of d
    exports[key]    = d[key]

