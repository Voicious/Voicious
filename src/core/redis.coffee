RedisDriver = require 'redis'
{Database} = require './database'
{Errors} = require './errors'

class Redis extends Database
        constructor: (dbName, dbHost = "localhost", dbPort = 6379, dbOptions = {}) ->
            super dbName, dbHost, dbPort, dbOptions

        connect : (callback) ->
            @client = RedisDriver.createClient @dbPort, @dbHost, @dbOptions
            @client.on "ready", () =>
                do callback
            @client.on "error", (err) =>
                throw new Errors.Error err

        insert : (filename, data, callback) ->
            @client.hincrby ['unique_ids', filename, 1], (err, res) =>
                if err
                    throw new Errors.Error err
                query = [filename + ':' + res, "id", res]
                for field in data
                    query.push field
                @client.hmset query, (err, res) =>
                    if err
                        throw new Errors.Error err
                    do callback

        update : (filename, data, callback) ->
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

        get : (filename, query, opts, callback) ->
            @client.hgetall filename, (err, res) =>
                if err
                    throw new Errors.Error err
                callback res

        close : () ->
            do @client.quit

exports.Redis = Redis