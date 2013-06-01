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

Config          = require '../common/config'
{Database}      = require './database'
{Errors}        = require './errors'

class _Mongo extends Database
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
            collName = collName.split(':')
            if collName.length != 2
                throw new Errors.Error "Error : wrong format for querying insertion"
            coll = @db.collection collName[0]
            data['_id'] = collName[1]
            coll.insert data, (err) =>
                if err
                    throw Errors.Error err
                do callback

        update : (collName, cur, callback) ->
            collName = collName.split(':')
            if collName.length != 2
                throw new Errors.Error "Error : wrong format for querying update"
            coll = @db.collection collName[0]
            coll.update {'_id': collName[1]}, {$set: cur}, {safe: on}, (err) =>
                if err
                    throw Errors.Error err
                do callback

        get : (collName, callback) ->
            collName = collName.split(':')
            if collName.length != 2
                throw new Errors.Error "Error : wrong format for querying get"
            coll = @db.collection collName[0]
            coll.findOne {'_id': collName[1]}, (err, doc) =>
                if err
                    throw Errors.Error err
                callback doc

        delete : (collName, callback) ->
            collName = collName.split(':')
            if collName.length != 2
                throw new Errors.Error "Error : wrong format for querying delete"
            coll = @db.collection collName[0]
            coll.remove {'_id': collName[1]}, {}, (err) =>
                if err
                    throw Errors.Error err
                do callback

        close : () ->
            do @db.close

class Mongo
    @_instance   = undefined
    @get        : () ->
        @_instance   ?= new _Mongo Config.Database.Name, Config.Database.Host

exports.Db = do Mongo.get