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

md5             = require 'MD5'

{Errors}        = require '../common/errors'
Config          = require '../common/config'
{Stats}         = require './stats'
{Db}            = require '../common/' + Config.Database.Connector

class _User
    constructor : () ->

    # Called for inserting a new user in database.
    # Check Validity of all the values (mail, name, etc).
    # If everything is ok, create the user, log him in and redirect into room (only room for the moment).
    newUser : (req, res, param, callback) =>
        Db.insert 'user', param, (newitem) =>
            req.session.uid = newitem._id
            callback req, res
            # Stats.countTmpUser req, res, callback

    # Called for registering a user.
    # Check sanity of all values and called the method newUser to create a new user.
    # if something went wrong, render the home page with the errors setted.
    register : (req, res, next) =>
        param   = req.body
        if param.name?
            if param.mail?
                if param.password? and param.passwordconfirm?
                    if param.passwordconfirm isnt param.password
                        Errors.RenderPageOnError req, res, 'home', {'hash': '#signup'}, [{'form': 'signup', 'input': 'password', 'message': 'Passwords are not matching'}]
                    else
                        Db.find 'user', {'name': param.name}, (body) =>
                            if not body? or body.length is 0
                                Db.find 'user', {'mail': param.mail}, (body) =>
                                    if not body? or body.length is 0
                                        param.password = md5(param.password)
                                        delete param.passwordconfirm
                                        param.id_acl = 0 #TO DO : put the right value
                                        param.id_role = 0 #TO DO : put the right value
                                        @newUser req, res, param, (req, res) =>
                                            {Room} = require './room'
                                            Room.newRoom req, res, {}
                                    else
                                        Errors.RenderPageOnError req, res, 'home', {'hash': '#signup'}, [{'form': 'signup', 'input': 'mail', 'message': 'This mail is already used'}]
                            else
                                Errors.RenderPageOnError req, res, 'home', {'hash': '#signup'}, [{'form': 'signup', 'input': 'name', 'message': 'This nickname is already used'}]
                else
                    Errors.RenderPageOnError req, res, 'home', {'hash': '#signup'}, [{'form': 'signup', 'input': 'password', 'message': 'Missing field password'}]
            else
                Errors.RenderPageOnError req, res, 'home', {'hash': '#signup'}, [{'form': 'signup', 'input': 'mail', 'message': 'Missing field mail'}]
        else
            Errors.RenderPageOnError req, res, 'home', {'hash': '#signup'}, [{'form': 'signup', 'input': 'name', 'message': 'Missing field name'}]

    # Called for loging in a user.
    # Check sanity of all values and render the home page if any value is wrong.
    # if everything is ok, log the user in and redirect him into room.
    login : (req, res, next) =>
        param       = req.body
        if param.name?
            if param.password?
                Db.find 'user', {'name': param.name, 'password': md5(param.password)}, (body) =>
                    if not body? or body.length is 0
                        Db.find 'user', {'mail': param.name, 'password': md5(param.password)}, (body) =>
                            if not body? or body.length is 0
                                Errors.RenderPageOnError req, res, 'home', {'hash': '#signin'}, [{'form': 'signin', 'input': 'name', 'message': 'The username or password is incorrect'}]
                            else
                                @goToDashboard req, res, body
                    else
                        @goToDashboard req, res, body
            else
                Errors.RenderPageOnError req, res, 'home', {'hash': '#signin'}, [{'form': 'signin', 'input': 'name', 'message': 'Missing field password'}]
        else
            Errors.RenderPageOnError req, res, 'home', {'hash': '#signin'}, [{'form': 'signin', 'input': 'name', 'message': 'Missing field nickname'}]

     goToDashboard : (req, res, userData) =>
        req.body = userData
        req.session.uid = userData._id
        {Room} = require './room'
        Room.newRoom req, res, {}

    # Called when non registered user create a Room.
    # Check if the name of the user is correctly set, if not render the home page.
    # if everything is ok, create and log the user in and redirect him into room.
    quickLogin : (req, res, next) =>
        param = req.body
        if param.name? and param.name isnt ""
           Db.find 'user', {'name': param.name}, (body) =>
                if not body? or body.length is 0
                    @newUser req, res, param, (req, res) =>
                        {Room}  = require './room'
                        Room.newRoom req, res, {}
                else
                    Errors.RenderPageOnError req, res, 'home', {'hash': '#quick'}, [{'form': 'quicklogin', 'input': 'name', 'message': 'Nickname already used'}]
        else
            Errors.RenderPageOnError req, res, 'home', {'hash': '#quick'}, [{'form': 'quicklogin', 'input': 'name', 'message': 'Missing field nickname'}]

    # Called when a not registered user wants to join a Room.
    # Check if the login and the Room id are correctly set, if not, redirect to the home page.
    # If everything is ok, create the user and redirect him into the Room.
    quickJoin : (req, res, next) =>
        param = req.body
        if param.name? and param.name isnt ""
            Db.find 'user', {'name': param.name}, (body) =>
                if not body? or body.length is 0
                    if param.room? and param.room isnt ""
                        rid             = param.room
                        delete param.room
                        param.mail      = param.name + do Date.now
                        @newUser req, res, param, (req, res) =>
                            res.redirect "/room/#{rid}"
                    else
                        Errors.RenderPageOnError req, res, 'home', {'hash': '#quick'}, [{'form': 'quickjoin', 'input': 'room', 'message': 'Missing field room'}]
                else
                    Errors.RenderPageOnError req, res, 'home', {'hash': '#quick'}, [{'form': 'quickjoin', 'input': 'name', 'message': 'Nickname already used'}]
        else
            Errors.RenderPageOnError req, res, 'home', {'hash': '#quick'}, [{'form': 'quickjoin', 'input': 'name', 'message': 'Missing field nickname'}]

    join        : (req, res, next) =>
        roomIdentifier = req.body.room
        if roomIdentifier? and roomIdentifier isnt ""
            res.redirect "room/#{roomIdentifier}"
        else
            res.redirect 'Dashboard'

    createRoom : (req, res, next) =>
        {Room}  = require './room'
        Room.newRoom req, res, { }

exports.User    = new _User
exports.Routes  =
    post :
        '/register'     : exports.User.register
        '/login'        : exports.User.login
        '/quickLogin'   : exports.User.quickLogin
        '/quickJoin'    : exports.User.quickJoin
        '/join'         : exports.User.join
        '/create'       : exports.User.createRoom
