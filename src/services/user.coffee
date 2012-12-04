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

Database    = require '../core/database'
BaseService = (require './service').BaseService

class Model
    @_name      : do () ->
        return {
            get : () -> 'user'
        }

    @_schema    : do () ->
        return {
            get : () ->
                return {
                    name    :
                        type    : String
                        length  : 255
                        index   : true
                    mail        :
                        type    : String
                        length  : 255
                    password:
                        type    : String
                        length  : 255
                    id_acl  :
                        type    : Number
                    id_role :
                        type    : Number
                    c_date  :
                        type    : Date
                        default : Date.now
                    last_con:
                        type    : Date
                }
        }

    @_instance  : do () ->
        instance    = undefined
        return {
            get : () =>
                return instance
            set : (val) =>
                instance    = val
        }

    @get        : () ->
        if do @_instance.get == undefined
            definition = Database.createTable do @_name.get, do @_schema.get
            definition.validatesPresenceOf 'name', 'mail', 'password', 'id_acl', 'id_role'
            definition.validatesUniquenessOf 'mail',
                message : 'This mail address is already used.'
            definition.validatesUniquenessOf 'name',
                message : 'This name is already used.'
            definition.validatesNumericalityOf 'id_acl', 'id_role'
            @_instance.set definition
        do @_instance.get

class _User extends BaseService
    constructor : () ->
        @Model  = do Model.get

    default : (req, res) =>
        param = req.body
        if param.mail? and param.password?
            param.name = param.mail
            param.id_acl = 0 #TO DO : put the right value
            param.id_role = 0 #TO DO : put the right value
            user = new @Model param
            user.isValid (valid) =>
                if not valid
                   console.log user.errors
                else
                   @Model.create user, (err, data) =>
                       if err
                           console.log err
                       res.redirect '/room'


class User
    @instance   : do () ->
        instance    = undefined
        return {
            get : () =>
                return instance
            set : (val) =>
                instance    = val
        }

    @get        : () ->
        if do @instance.get is undefined
            @instance.set new _User
        do @instance.get

exports.User    = do User.get

exports.Routes  =
    post :
        '/user' : (do User.get).default