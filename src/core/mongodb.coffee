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

MongoDB = require 'mongodb'
{Database} = require './database'
{Errors} = require './errors'

class Mongo extends Database
        constructor : (dbName, dbHost = 'localhost', dbPort = 27017, dbOptions = {}) ->
                super dbName, dbHost, dbPort, dbOptions

        connect : (callback) ->
            @server = MongoDB.Server @dbHost, @dbPort
            @db = MongoDB.Db @dbName, @server, {w: 1}
            @db.open (err, coll) =>
                if err
                    throw Errors.Error err
                do callback

        insert : (collName, data, callback) ->
            coll = @db.collection(collName)
            coll.insert data, (err) =>
                if err
                    throw Errors.Error err
                do callback

        update : (collName, old, cur, callback) ->
            coll = @db.collection(collName)
            coll.update old, {$set: cur}, {safe: on}, (err) =>
                if err
                    throw Errors.Error err
                do callback

        get : (collName, query, opts, callback) ->
            coll = @db.collection(collName)
            coll.find(query, {}, opts).toArray (err, docs) =>
                if err
                    throw Errors.Error err
                callback docs

        delete : (collName, query, callback) ->
            coll = @db.collection(collName)
            coll.remove query, {}, (err) =>
                if err
                    throw Errors.Error err
                do callback

        close : () ->
            do @db.close

exports.Mongo = Mongo