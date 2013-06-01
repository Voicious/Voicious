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

Config          = require '../common/config'
{Database}      = require './database'
{Errors}        = require './errors'

class _Redis extends Database
        constructor: (dbName, dbHost = "localhost", dbPort = 6379, dbOptions = {}) ->
            super dbName, dbHost, dbPort, dbOptions

        connect : (callback) ->
            @client = RedisDriver.createClient @dbPort, @dbHost, @dbOptions
            @client.on "ready", () =>
                do callback
            @client.on "error", (err) =>
                throw new Errors.Error err

        insert : (filename, data, callback) ->
            data = @objToArray data
            filename = filename.split(':')
            if filename.length != 2
                throw new Errors.Error "Error : wrong format for querying insertion"
            query = [filename.join(':'), "_id", filename[1]]
            for field in data
                query.push field
             @client.hmset query, (err, res) =>
                 if err
                     throw new Errors.Error err
                 do callback

        update : (filename, data, callback) ->
            data = @objToArray data
            @client.hlen filename, (err, res) =>
                if err
                    throw new Errors.Error err
                if res is 0
                    throw new Errors.Error "Error : trying to update an empty set"
                else
                    query = [filename]
                    for field in data
                        query.push field
                    @client.hmset query, (err, res) =>
                        if err
                            throw new Errors.Error err
                        do callback

        delete : (filename, callback) ->
            data = @objToArray data
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

        get : (filename, callback) ->
            data = @objToArray data
            @client.hgetall filename, (err, res) =>
                if err
                    throw new Errors.Error err
                callback res

        close : () ->
            do @client.quit

        objToArray: (obj) ->
            arr = []
            for key, val of obj
                arr.push key, val
            return arr

class Redis
    @_instance   = undefined
    @get        : () ->
        @_instance   ?= new _Redis Config.Database.Name, Config.Database.Host

exports.Db = do Redis.get