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

Config = require './config'


class Database
    constructor: () ->
        @Schema = new Schema Config.Database.connector, Config.Database
        @Tables = {};

    createTable: (tableName, schema) ->
        @Tables[tableName] = @Schema.define tableName, schema

    flushTable: (callback) ->
        @Schema.automigrate callback

    insert: (tableName, queryObj, callback) ->
        @Tables[tableName].create queryObj, callback

    close: () ->
        @Schema.disconnect()

exports.Database = Database

#Schema = (require 'jugglingdb').Schema

#schema = new Schema 'sqlite3', {port: 27017, database: 'Users.db'}

#User = schema.define 'user', {
#    name:      { type: String, index: true },
#    email:     { type: String, index: true }
#    }

#schema.automigrate () ->
#    User.create {name: 'Alex', email: 'alexandre.loyer@outlook.com'}, (err, data) ->
#        console.log err

#schema.disconnect()