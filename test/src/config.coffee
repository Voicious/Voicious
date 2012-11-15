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

Vows        = require 'vows'
Assert      = require 'assert'
Http        = require 'http'
Config      = (require '../www/lib/core/config')

api =
    isObject            : () ->
        return (o) ->
            Assert.isObject o

    isDefined           : () ->
        return (o) ->
            Assert.isNotNull o

    isChildrenDefined   : (children) ->
        return (o) ->
            Assert.isNotNull o[children]

((Vows.describe "Voicious' Configuration").addBatch
    'Global'    :
        topic   : Config
        'Configuration seems legit' : do api.isObject
    'Network'   :
        topic   : Config.Port
        'Contains Port'     : do api.isDefined
    'Logger'    :
        topic   : Config.Logger
        'Contains Logger'           : do api.isDefined
        'Contains Logger.Level'     : api.isChildrenDefined 'Level'
        'Contains Logger.Stdout'    : api.isChildrenDefined 'Stdout'
    'Dirs'      :
        topic   : Config.Dirs
        'Contains Dirs'         : do api.isDefined
        'Contains Dirs.Static'  : api.isChildrenDefined 'Static'
    'Paths'     :
        topic   : Config.Paths
        'Contains Paths'                : do api.isDefined
        'Contains Paths.Approot'        : api.isChildrenDefined 'Approot'
        'Contains Paths.Webroot'        : api.isChildrenDefined 'Webroot'
        'Contains Paths.Logs'           : api.isChildrenDefined 'Logs'
        'Contains Paths.Config'         : api.isChildrenDefined 'Config'
        'Contains Paths.Views'          : api.isChildrenDefined 'Views'
        'Contains Paths.Services'       : api.isChildrenDefined 'Services'
        'Contains Paths.StaticServices' : api.isChildrenDefined 'StaticServices'
    'Database'  :
        topic   : Config.Database
        'Contains Database'             : do api.isDefined
        'Database seems legit'          : do api.isObject
        'Contains Database.Connector'   : api.isChildrenDefined 'Connector'
).export module
