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

{Schema}    = require 'jugglingdb'
Config      = require './config'

class _Database
    constructor: () ->
        @Db = undefined

    connect: () ->
        @Db  = new Schema Config.Database.connector, Config.Database

    createTable: (tableName, schema) ->
        @Db[tableName] = @Db.define tableName, schema

    flushTable: (callback) ->
        @Db.automigrate callback

    insert: (tableName, queryObj, callback) ->
        @Db[tableName].create queryObj, callback

    get: (tableName, query, callback)  ->
        @Db[tableName].all query, callback

    close: () ->
        @Db?.disconnect()

class Database
    @_instance = undefined

    @get : () ->
        @_instance ?= new _Database

d = do Database.get
for key of d
    exports[key]    = d[key]

