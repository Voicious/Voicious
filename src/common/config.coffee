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

Path    = require 'path'

class _Config
    loadDatabaseConfig  : (dbConfig)    ->
        if dbConfig is undefined
            throw new (Error "A database must be configured in etc/config.json !")

        @Database   =
            connector   : dbConfig.connector
            user        : dbConfig.user
            password    : dbConfig.password
            database    : dbConfig.database

    loadRestApiConfig   : (restApiConfig) ->
        @RestAPI    =
            Enabled         : restApiConfig.enabled
            Host            : restApiConfig.hostname
            Port            : restApiConfig.port
            AllowedHosts    : [ "http://#{@HostName}:#{@Port}" ]
            Url             : "http://#{restApiConfig.hostname}:#{restApiConfig.port}/api"
        if (typeof restApiConfig["allowed-hosts"]) is (typeof [])
            for allowedHost in restApiConfig["allowed-hosts"]
                @RestAPI.AllowedHosts.push allowedHost
        else if (typeof restApiConfig["allowed-hosts"]) is (typeof "")
            @RestAPI.AllowedHosts.push restApiConfig["allowed-hosts"]

    loadConfigJSON      : ()            ->
        fileToOpen  = 'config'
        if process.env.NODE_ENV
            fileToOpen  += '.' + process.env.NODE_ENV
        tmpJSON     = require (Path.join @Paths.Config, fileToOpen + ".json")

        @HostName   = tmpJSON.voicious.hostname
        @Port       = tmpJSON.voicious.port
        @Enabled    = tmpJSON.voicious.enabled

        @loadDatabaseConfig (tmpJSON.database || undefined)

        @loadRestApiConfig (tmpJSON.restapi || undefined)

        @Acl        = tmpJSON.voicious.acl

        @Roles      = tmpJSON.voicious.roles

    constructor         : ()            ->
        @Title  = 'voıċıoųs'
        @Paths  =
            Webroot : Path.join __dirname, '..', '..', 'www'
        @Paths.Approot          = Path.join @Paths.Webroot, '..'
        @Paths.Config           = Path.join @Paths.Approot, 'etc'
        @Paths.Views            = Path.join @Paths.Webroot, 'views'
        @Paths.Static           = Path.join @Paths.Webroot, 'public'
        @Paths.Services         = Path.join __dirname, '..', 'core'

        do @loadConfigJSON


class Config
    @_instance  = undefined
    @get        : () ->
        @_instance  ?= new _Config

c   = do Config.get
for key of c
    exports[key]    = c[key]
