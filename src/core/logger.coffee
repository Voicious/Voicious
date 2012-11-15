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

path    = require 'path'
fs      = require 'fs'
moment  = require 'moment'

Config  = require './config'

Loggers = {}
Logger = {
    DEBUG   : 0
    INFO    : 1
    WARN    : 2
    ERROR   : 3
    FATAL   : 4

    get: (name) ->
        if not Loggers[name]?
            Loggers[name]   = new _Logger name
        Loggers[name]

    getLevelFromString  : (str) ->
        switch str
            when "debug"    or "DEBUG"  then return Logger.DEBUG
            when "info"     or "INFO"   then return Logger.INFO
            when "warn"     or "WARN"   then return Logger.WARN
            when "error"    or "ERROR"  then return Logger.ERROR
            when "fatal"    or "FATAL"  then return Logger.FATAL
}

class _Logger
    constructor: (name) ->
        @name   = name
        if not fs.existsSync Config.Paths.Logs
            fs.mkdirSync Config.Paths.Logs


    _log: (level, message) ->
        if message instanceof Object
            return
        if level >= Config.Logger.Level
            theLog  = "[" + switch level
                when Logger.DEBUG      then "DEBUG"
                when Logger.INFO       then "INFO"
                when Logger.WARN       then "WARN"
                when Logger.ERROR      then "ERROR"
                when Logger.FATAL      then "FATAL"
            theLog  += "] " + (do moment).format 'MMMM Do YYYY, h:mm:ss a : '
            theLog  += message
            fd      = fs.openSync (path.join Config.Paths.Logs, @name + '.log'), 'a'
            fs.writeSync fd, theLog + '\n', 0, theLog.length + 1, null
            fs.closeSync fd
            if Config.Logger.Stdout
                console.log theLog

    debug:  (message) ->
        @_log(Logger.DEBUG, message)
    info:   (message) ->
        @_log(Logger.INFO, message)
    warn:   (message) ->
        @_log(Logger.WARN, message)
    error:  (message) ->
        @_log(Logger.ERROR, message)
    fatal:  (message) ->
        @_log(Logger.FATAL, message)

exports.get                 = Logger.get
exports.getLevelFromString  = Logger.getLevelFromString
exports.DEBUG               = Logger.DEBUG
exports.INFO                = Logger.INFO
exports.WARN                = Logger.WARN
exports.ERROR               = Logger.ERROR
exports.FATAL               = Logger.FATAL
