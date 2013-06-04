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

RedisDriver     = require 'redis'
MD5             = require 'MD5'

Config          = require '../common/config'
{Database}      = require './database'
{Errors}        = require './errors'

class _Redis extends Database
        constructor: (dbName, dbHost = "localhost", dbPort = 6379, dbOptions = {}) ->
            super dbName, dbHost, dbPort, dbOptions
            @_lastKnownId = { }

        connect : (callback) ->
            @client = RedisDriver.createClient @dbPort, @dbHost, @dbOptions
            @client.on "ready", () =>
                do callback
            @client.on "error", (err) =>
                throw err

        afterIdFound : (filename, callback) =>
            if not @_lastKnownId[filename]?
                @_lastKnownId[filename] = 1
            @client.hgetall filename + ':' + (MD5 @_lastKnownId[filename]), (err, item) =>
                if item?
                    ++@_lastKnownId[filename]
                    @afterIdFound filename, callback
                else
                    callback (MD5 @_lastKnownId[filename])

        insert : (filename, data, callback) =>
            @afterIdFound filename, (id) =>
                data.__type = filename
                @client.hmset filename + ':' + id, data, (err, res) =>
                    if err
                        throw new Errors.Error err
                    data._id = id
                    callback data

        update : (filename, id, data, callback) =>
            if data._id?
                delete data._id
            data.__type = filename
            filename    = filename + ':' + id
            @client.hlen filename, (err, res) =>
                if err
                    throw new Errors.Error err
                if res is 0
                    throw new Errors.Error "Error : trying to update an empty set"
                else
                    @client.hmset filename, data, (err, res) =>
                        if err
                            throw new Errors.Error err
                        do callback

        delete : (filename, id, callback) =>
            filename = filename + ':' + id
            @client.hkeys filename, (err, res) =>
                if err
                    throw new Errors.Error err
                data = [filename]
                for field in res
                    data.push field
                @client.hdel data, (err, result) =>
                    if err
                        throw new Errors.Error err
                    do callback

        get : (filename, id, callback) ->
            filename = filename + ':' + id
            @client.hgetall filename, (err, res) =>
                if err
                    throw new Errors.Error err
                res._id = id
                callback res

        close : () ->
            do @client.quit

class Redis
    @_instance   = undefined
    @get        : () ->
        @_instance   ?= new _Redis Config.Database.Name, Config.Database.Host

exports.Db = do Redis.get
