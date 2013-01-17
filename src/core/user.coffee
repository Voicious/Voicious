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

Request         = require 'request'
md5             = require 'MD5'
{Errors}        = require './errors'
Config          = require '../common/config'

class _User
    constructor : () ->

    # Render the home page
    # This function is called when there is an error during registration
    errorOnRegistration : (err, req, res) =>
        options =
            erroron         : err
            hash            : '#signUp'
            login_email     : ''
            signup_email    : req.body.mail || ''
            name            : ''
            title           : Config.Voicious.Title
        res.render 'home', options

    # Render the home page
    # This function is called when there is an error during quick log in
    errorOnQuickLogin : (err, req, res) =>
        options =
            error        : err
            hash         : '#jumpIn'
            login_email  : ''
            signup_email : ''
            name         : req.body.name || ''
            title        : Config.Voicious.Title
        res.render 'home', options

    # Called for inserting a new user in database
    # Check Validity of all the values (mail, name, etc)
    # If everything is ok, create the user, log him in and redirect into room (only room for the moment)
    newUser : (req, res, param, callback, errorCallback) =>
        Request.post {
            json    : param
            url     : "#{Config.Restapi.Url}/user"
        }, (e, r, body) =>
            if e? or r.statusCode > 200
                errorCallback e, req, res
            else
                req.session.uid = body.id
                callback req, res

    redirtoroom : (req, res) =>
        res.redirect '/room'

    # Called for registering a user
    # Check sanity of all values and called the method newUser to create a new user
    # if something went wrong, render the home page with the errors setted
    register : (req, res, next) =>
        param   = req.body
        err     = []
        if param.mail?
            if param.password? and param.passwordconfirm?
                if param.passwordconfirm isnt param.password
                    err.push "signup_password"
                else
                    param.password = md5(param.password)
                    param.name = param.mail
                    param.id_acl = 0 #TO DO : put the right value
                    param.id_role = 0 #TO DO : put the right value
                    @newUser req, res, param, @redirtoroom, @errorOnRegistration
            else
                err.push 'signup_password'
        else
            err.push 'signup_email'
        if err.length > 0
            err = JSON.stringify err
            @errorOnRegistration err, req, res

    # Called for loging in a user
    # Check sanity of all values and render the home page if any value is wrong
    # if everything is ok, log the user in and redirect him into room
    login : (req, res, next) =>
        param       = req.body
        errorOpts   =
            hash            : '#logIn'
            login_email     : ''
            signup_email    : ''
            name            : ''
            erroron         : []
            title           : Config.Voicious.Title
        if param.mail?
            if param.password?
                Request.get "#{Config.Restapi.Url}/user?mail=#{param.mail}&password=#{md5(param.password)}", (e, r, data) =>
                    if (typeof data) is (typeof "")
                        data    = JSON.parse data
                    if e
                        return (next (new Errors.Error e[0]))
                    else if data.length > 0
                        req.session.uid = data[0].id
                        res.redirect '/room'
                    else
                        res.render 'home', errorOpts
            else
                errorOpts.erroron.push 'login_password'
        else
            errorOpts.erroron.push 'login_email'
        if errorOpts.erroron.length > 0
            errorOpts.erroron   = JSON.stringify errorOpts.erroron
            res.render 'home', errorOpts

    # Called when non registered user create a Room
    # Check if the name of the user is correctly set, if not render the home page
    # if everything is ok, create and log the user in and redirect him into room
    quickLogin : (req, res, next) =>
        param = req.body
        if param.name? and param.name isnt ""
            param.mail = param.name + do Date.now
            param.id_acl = 0 #TO DO : put the right value
            param.id_role = 0 #TO DO : put the right value
            @newUser req, res, param, ((req, res) =>
                {Room}  = require './room'
                Room.newRoom req, res, { }
            ), @errorOnQuickLogin
        else
            @errorOnQuickLogin 'Missing field : Nickname', req, res

    quickJoin : (req, res, next) =>
        param = req.body
        if param.name? and param.name isnt ""
            if param.room? and param.room isnt ""
                param.mail      = param.name + do Date.now
                param.id_acl    = 0
                param.id_role   = 0
                @newUser req, res, param, ((req, res) =>
                    res.redirect "/room/#{param.room}"
                ), @errorOnQuickLogin

exports.User    = new _User
exports.Routes  =
    post :
        '/user'         : exports.User.register
        '/login'        : exports.User.login
        '/quickLogin'   : exports.User.quickLogin
        '/quickJoin'    : exports.User.quickJoin
