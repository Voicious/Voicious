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

md5             = require 'MD5'

Database        = require '../core/database'
BaseService     = (require './service').BaseService
{Errors}        = require '../core/errors'

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

    # Render the home page
    # This function is called when there is an error during registration
    errorOnRegistration : (err, req, res) =>
        options =
            error   : err
            hash    : '#signUp'
            email   : req.body.mail || ''
            name    : ''
        res.render 'home', options

    # Render the home page
    # This function is called when there is an error during quick log in
    errorOnQuickLogin : (err, req, res) =>
        console.log "On quick Login Error"
        options =
            error   : err
            hash    : '#jumpIn'
            email   : ''
            name    : req.body.name || ''
        console.log options
        res.render 'home', options

    # Called for inserting a new user in database
    # Check Validity of all the values (mail, name, etc)
    # If everything is ok, create the user, log him in and redirect into room (only room for the moment)
    newUser : (req, res, param, errorCallback) =>
        user = new @Model param
        {Room} = require('./room')
        user.isValid (valid) =>
            if not valid
                for key, value of user.errors
                    if value?
                        return errorCallback value[0], req, res
            else
                @Model.create user, (err, data) =>
                    if err
                        return (next (new Errors.Error err[0]))
                    req.session.uid = data.id
                    param.room = (md5(do Date.now)).substr 0, 10
                    param.name = param.room
                    param.oid = data.id
                    Room.newRoom req, res, param, @errorOnQuickLogin

    # Called for registering a user
    # Check sanity of all values and called the method newUser to create a new user
    # if something went wrong, render the home page with the errors setted
    register : (req, res, next) =>
        param = req.body
        if param.mail? and param.password? and param.passwordconfirm?
            if param.passwordconfirm isnt param.password
                @errorOnRegistration "Password and confirmation do not match !<br />", req, res
            else
                param.password = md5(param.password)
                param.name = param.mail
                param.id_acl = 0 #TO DO : put the right value
                param.id_role = 0 #TO DO : put the right value
                @newUser req, res, param, @errorOnRegistration
        else
            err   = ''
            err   += 'Missing field : Email<br />' if not param.mail
            if not param.password
                err += 'Missing field : Password<br />'
            else if not param.passwordconfirm
                err += 'Missing field : Password<br />'
            @errorOnRegistration err, req, res

    # Called for loging in a user
    # Check sanity of all values and render the home page if any value is wrong
    # if everything is ok, log the user in and redirect him into room
    login : (req, res, next) =>
        param = req.body
        if param.mail? and param.password?
            @Model.all {where: {mail: param.mail, password: md5(param.password)}}, (err, data) =>
                if err
                    return (next (new Errors.Error err[0]))
                else if data[0] isnt undefined
                    req.session.uid = data[0].id
                    res.redirect '/room'
                else
                    options =
                        error   : 'Incorrect email or password'
                        hash    : '#logIn'
                        email   : ''
                        name    : ''
                    res.render 'home', options
        else
            throw new Errors.error "Internal Server Error"

    # Called when non registered user create a Room
    # Check if the name of the user is correctly set, if not render the home page
    # if everything is ok, create and log the user in and redirect him into room
    quickLogin : (req, res, next) =>
        param = req.body
        if param.name? and param.name isnt ""
            param.mail = param.name + do Date.now
            param.id_acl = 0 #TO DO : put the right value
            param.id_role = 0 #TO DO : put the right value
            @newUser req, res, param, @errorOnQuickLogin
        else
            @errorOnQuickLogin 'Missing field : Nickname', req, res

exports.User    = new _User
exports.Routes  =
    post :
        '/user'         : exports.User.register
        '/login'        : exports.User.login
        '/quickLogin'   : exports.User.quickLogin
