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
{User}          = require './user'
{Session}       = require './session'
md5             = require 'MD5'

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
                        definition.belongsTo User.Model,
                                as         : 'param'
                                foreignKey : 'oid'
                        definition.validatesPresenceOf 'name'
                        @_instance.set definition
                do @_instance.get

class _Room extends BaseService
        @default : (req, res, param) ->
                user = req.currentUser
                options =
                        title   : 'Voicious'
                        login   : 'Paulloz'
                        room    : 'rgz4zgzr'
                res.render 'room/room', options

        constructor : () ->
                @Model = do Model.get

        newRoom : (req, res, param, errorCallback) =>
                room = new @Model param
                room.isValid (valid) =>
                        if not valid
                                for key, value of room.errors
                                        if value?
                                                return errorCallback value[0], req, res
                        else
                                @Model.create room, (err, data) =>
                                        if err
                                                return (next (new Errors.Error err[0]))
                                        res.redirect '/room'
exports.Room    = new _Room
exports.Routes  =
    get :
        '/room' : Session.ifUser.curry _Room.default