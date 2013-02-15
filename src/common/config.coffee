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

class _Config
    checkCoreConfig : () ->
        @Voicious.Enabled  = 0           if not @Voicious.Enabled?
        @Voicious.Hostname = DefaultHostname @Voicious.Hostname
        @Voicious.Port     = 4242        if not @Voicious.Port?

    checkRestConfig : () ->
        @Restapi.Enabled = 0 if not @Restapi.Enabled?
        if @Restapi.Enabled
            if not @Restapi.Database.Connector?
                throw "Must provice a database connector if enabling REST API."
            @Restapi.Hostname         = DefaultHostname @Restapi.Hostname
            @Restapi.Port             = 4243        if not @Restapi.Port?
            @Restapi['Allowed-hosts'] = [ ]         if not @Restapi['Allowed-hosts']?
            if (typeof @Restapi['Allowed-hosts']) is (typeof "")
                @Restapi['Allowed-hosts'] = [ @Restapi['Allowed-hosts'] ]
            @Restapi['Allowed-hosts'].push "http://#{@Voicious.Hostname.Internal}:#{@Voicious.Port}"
            @Restapi['Allowed-hosts'].push "http://#{@Voicious.Hostname.External}:#{@Voicious.Port}"
            if @Restapi.Ssl?
                if @Restapi.Ssl.Key? and @Restapi.Ssl.Certificate?
                    @Restapi.Ssl.Enabled = 1
                else
                    @Restapi.Ssl.Enabled = 0
            else
                @Restapi.Ssl =
                    Enabled : 0
            protocol     = if @Restapi.Ssl.Enabled then 'https' else 'http'
            @Restapi.Url = "#{protocol}://#{@Restapi.Hostname.Internal}:#{@Restapi.Port}/api"

    checkWebsocketConfig : () ->
        @Websocket.Enabled  = 0           if not @Websocket.Enabled?
        @Websocket.Hostname = DefaultHostname @Websocket.Hostname
        @Websocket.Port     = 1337        if not @Websocket.Port?

    loadJSONConfig : () ->
        fileToOpen  = 'config'
        tmpJSON     = require (Path.join @Paths.Config, fileToOpen + ".json")
        for key, val of tmpJSON
            @[key]  = val
        do @checkCoreConfig
        do @checkRestConfig
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
