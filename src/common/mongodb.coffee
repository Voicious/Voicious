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

MongoDB         = require 'mongodb'

Config          = require './config'
{Database}      = require './database'
{Errors}        = require './errors'

class _Mongo extends Database
        constructor : (dbName, dbHost = 'localhost', dbPort = 27017, dbOptions = {}) ->
                super dbName, dbHost, dbPort, dbOptions

        connect : (callback) =>
            @server = MongoDB.Server @dbHost, @dbPort
            @db = MongoDB.Db @dbName, @server, {w: 1}
            @db.open (err, coll) =>
                if err
                    throw err
                do callback

        insert : (collName, data, callback) =>
            coll = @db.collection collName
            coll.insert data, { safe : on }, (err, item) =>
                if err
                    throw err
                callback item[0]

        update : (collName, id, cur, callback) =>
            coll = @db.collection collName
            if cur._id?
                delete cur._id
            coll.update {'_id': new MongoDB.ObjectID(String(id))}, {$set: cur}, {safe: on}, (err) =>
                if err
                    throw err
                do callback

        get : (collName, id, callback) =>
            coll = @db.collection collName
            coll.findOne {'_id': new MongoDB.ObjectID(String(id))}, (err, doc) =>
                if err
                    throw err
                callback doc

        find : (collName, filters, callback) =>
            coll = @db.collection collName
            if filters._id?
                filters._id = new MongoDB.ObjectID(String(filters._id))
            coll.findOne filters, (err, doc) =>
                if err
                    throw err
                callback doc

        delete : (collName, id, callback) =>
            coll = @db.collection collName
            coll.remove {'_id': new MongoDB.ObjectID(String(id))}, {}, (err) =>
                if err
                    throw err
                do callback

        close : () ->
            do @db.close

class Mongo
    @_instance   = undefined
    @get        : () ->
        @_instance   ?= new _Mongo Config.Database.Name, Config.Database.Host

exports.Db = do Mongo.get
