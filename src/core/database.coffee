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

Schema = (require 'jugglingdb').Schema

class _Database
    constructor: () ->
        @Databases = {'physic': null, 'memory': null}

    connect: (dbType, config) ->
        @Databases[dbType] = new Schema config.connector, config

    createTable: (dbType, tableName, schema) ->
        @Databases[dbType][tableName] = @Databases[dbType].define tableName, schema

    flushTable: (dbType, callback) ->
        @Databases[dbType].automigrate callback

    insert: (dbType, tableName, queryObj, callback) ->
        @Databases[dbType][tableName].create queryObj, callback

    get: (dbType, tableName, query, callback)  ->
        @Databases[dbType][tableName].all query, callback

    close: (dbType) ->
        @Databases[dbType]?.disconnect()

class Database
    @_instance = undefined

    @get : () ->
        @_instance ?= new _Database

d = do Database.get
for key of d
    exports[key]    = d[key]

