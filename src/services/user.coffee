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
{Errors}        = require '../core/errors'
md5             = require 'MD5'

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
            definition.validatesPresenceOf 'name', 'id_acl', 'id_role'
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

    errorOnRegistration : (err, req, res) =>
        options =
            error   : err
            hash    : '#signUp'
            email   : req.body.mail || ''
        res.render 'home', options

    default : (req, res, next) =>
        param = req.body
        if param.mail? and param.password? and param.passwordconfirm?
            if param.passwordconfirm isnt param.password
                @errorOnRegistration "Password and confirmation do not match !<br />", req, res
            else
                param.password = md5(param.password)
                param.name = param.mail
                param.id_acl = 0 #TO DO : put the right value
                param.id_role = 0 #TO DO : put the right value
                user = new @Model param
                user.isValid (valid) =>
                    if not valid
                        for key, value of user.errors
                            if value?
                                return @errorOnRegistration value[0], req, res
                    else
                        @Model.create user, (err, data) =>
                            if err
                                return (next (new Errors.Error err[0]))
                            res.redirect '/room'
        else
            error   = ''
            error   += 'Missing field : Email<br />' if not param.mail
            if not param.password
                err += 'Missing field : Password<br />'
            else if not param.passwordconfirm
                err += 'Missing field : Password<br />'
            @errorOnRegistration err, req, res

    login : (req, res, next) =>
        param = req.body
        if param.mail? and param.password?
            @Model.all {where: {mail: param.mail, password: md5(param.password)}}, (err, data) =>
                if err
                    return (next (new Errors.Error err[0]))
                else if data[0] isnt undefined
                    res.redirect '/room'
                else
                    options =
                        error   : 'Incorrect email or password'
                        hash    : '#logIn'
                        email   : ''
                    res.render 'home', options
        else
            throw new Errors.error "Internal Server Error"

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
        '/user/login' : (do User.get).login
