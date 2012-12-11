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

Database        = require '../core/database'
BaseService     = (require './service').BaseService
{Session}       = require './session'

class Model
        @_name : do () ->
                return {
                        get : () => 'room'
                }

        @_schema : do () ->
                return {
                        get : () ->
                                return {
                                        name :
                                                type   : String
                                                length : 255
                                        id_owner :
                                                type   : Number
                                }
                }

        @_instance : do () ->
                instance = undefined
                return {
                        get : () =>
                                return instance
                        set : (val) =>
                                instance = val
                }

        @get : () ->
                if do @_instance.get == undefined
                        definition = Database.createTable do @_name.get, do @_schema.get
                        definition.validatesPresenceOf 'name', 'id_owner'
                        definition.validatesNumericalityOf 'id_owner'
                        @_instance.set definition
                do @_instance.get

class Room
        @default : (req, res) ->
                options =
                        title   : 'Voicious'
                        login   : 'Paulloz'
                res.render 'room/room', options

exports.Routes  =
    get :
        '/room' : Session.ifUser.curry Room.default