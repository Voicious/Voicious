###

Copyright (c) 2011-2013  Voicious

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

# Define internal et external access adress.
DefaultHostname = (hostname, def = { Internal : '' , External : '' }) =>
    h =
        'Internal' : def.Internal or 'localhost'
        'External' : def.External or 'localhost'
    if hostname?
        if (typeof hostname) is (typeof "")
            h.Internal = hostname
            h.External = hostname
        else
            h.Internal = hostname.Internal if hostname.Internal?
            h.External = hostname.External if hostname.External?
    return h

# This class configure the entire project.
class _Config
    # Initialize Voicious config with basic value if configuration file doesn't
    # contain the required informations.
    checkCoreConfig : () ->
        @Voicious.Enabled  = 0           if not @Voicious.Enabled?
        @Voicious.Hostname = DefaultHostname @Voicious.Hostname
        @Voicious.Port     = 4242        if not @Voicious.Port?

    # Initialize the database config with basic value if configuration file doesn't
    # contain the required informations.
    checkDatabaseConfig : () ->
        @Database.Name      = "voicious"          if not @Database.Name?
        @Database.Connector = "mongodb"           if not @Database.Connector?
        @Database.Sessions  = 'mongo'             if @Database.Sessions is 'mongodb'
        @Database.Hostname  = DefaultHostname @Database.Hostname

    # Initialize the WebSocket server config with basic value if configuration file doesn't
    # contain the required informations.
    checkWebsocketConfig : () ->
        @Websocket.Enabled  = 0           if not @Websocket.Enabled?
        @Websocket.Hostname = DefaultHostname @Websocket.Hostname
        @Websocket.Port     = 4243        if not @Websocket.Port?

    # Initialize the Peerjs server config with basic value if configuration file doesn't
    # contain the required informations.
    checkPeerjsConfig : () ->
        @Peerjs.Enabled  = 0           if not @Peerjs.Enabled?
        @Peerjs.Hostname = DefaultHostname @Peerjs.Hostname
        @Peerjs.Port     = 4244        if not @Peerjs.Port?

    #
    checkSessionsConfig : () ->
        @Voicious.Sessions           = { }                 if not @Voicious.Sessions?
        @Voicious.Sessions.Connector = @Database.Connector if not @Voicious.Sessions.Connector
        if @Voicious.Sessions.Connector is 'mongodb'
            @Voicious.Sessions.Connector = 'mongo'
        @Voicious.Sessions.Hostname  = DefaultHostname @Voicious.Sessions.Hostname, @Database.Hostname

    # Load the configuration file.
    loadJSONConfig : () ->
        fileToOpen  = 'config'
        tmpJSON     = require (Path.join @Paths.Config, fileToOpen + ".json")
        for key, val of tmpJSON
            @[key]  = val
        do @checkCoreConfig
        do @checkDatabaseConfig
        do @checkWebsocketConfig
        do @checkPeerjsConfig
        do @checkSessionsConfig

    constructor : () ->
        @Paths  = {}
        @Paths.Root             = Path.join __dirname, '..'
        @Paths.Config           = Path.join @Paths.Root, '..', 'etc'
        @Paths.Webroot          = Path.join @Paths.Root, 'static'
        @Paths.Views            = Path.join @Paths.Root, 'views'
        @Paths.Logs             = Path.join @Paths.Root, '..', 'logs'

        do @loadJSONConfig
        @Voicious.Title = 'voıċıoųs'

class Config
    @_instance  = undefined
    @get        : () ->
        @_instance  ?= new _Config

c   = do Config.get
for key of c
    exports[key]    = c[key]
