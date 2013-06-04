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
DefaultHostname = (hostname) =>
    h =
        'Internal' : 'localhost',
        'External' : 'localhost'
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
        @Database.Enabled = 0           if not @Database.Enabled?
        @Database.Name = "voicious"     if not @Database.Name?
        @Database.Connector = "mongodb" if not @Database.Connector?
        @Database.Hostname = DefaultHostname @Database.Hostname

    # Initialize the WebSocket server config with basic value if configuration file doesn't
    # contain the required informations.
    checkWebsocketConfig : () ->
        @Websocket.Enabled  = 0           if not @Websocket.Enabled?
        @Websocket.Hostname = DefaultHostname @Websocket.Hostname
        @Websocket.Port     = 1337        if not @Websocket.Port?

    # Load the configuration file.
    loadJSONConfig : () ->
        fileToOpen  = 'config'
        tmpJSON     = require (Path.join @Paths.Config, fileToOpen + ".json")
        for key, val of tmpJSON
            @[key]  = val
        do @checkCoreConfig
        do @checkDatabaseConfig
        do @checkWebsocketConfig

    constructor : () ->
        @Paths  = {}
        @Paths.Root             = Path.join __dirname, '..', '..'
        @Paths.Config           = Path.join @Paths.Root, 'etc'
        @Paths.Webroot          = Path.join @Paths.Root, 'www'
        @Paths.Libroot          = Path.join @Paths.Root, 'lib'
        @Paths.Views            = Path.join @Paths.Webroot, 'views'
        @Paths.Logs             = Path.join @Paths.Root, 'logs'

        do @loadJSONConfig
        @Voicious.Title = 'voıċıoųs'

class Config
    @_instance  = undefined
    @get        : () ->
        @_instance  ?= new _Config

c   = do Config.get
for key of c
    exports[key]    = c[key]
