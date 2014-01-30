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
                                        param.registered = true
                                        delete param.passwordconfirm
                                        param.id_acl = 0 #TO DO : put the right value
                                        param.id_role = 0 #TO DO : put the right value
                                        param.friends = []
                                        @newUser req, res, param, (req, res) =>
                                            @goToDashboard req, res, req.body
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

    addFriend : (req, res, next) =>
        param   = req.body
        param._id = req.currentUser._id
        err     = []
        if param.name?
            Db.getBy 'user', {name : param.name}, (docs) =>
                if docs.length == 0
                    res.send 400 # Change to render a proper page TODO
                else
                    if param._id? and docs[0].registered is true
                        Db.get 'user', param._id, (user) =>
                            if !user?
                                res.send 400 # Change to render a proper page TODO
                            else if user.name isnt docs[0].name
                                if !user.friends?
                                    user.friends = []
                                else
                                    for friend of user.friends
                                        if friend.name == param.name
                                            res.send 400 # Change to render a proper page TODO
                                            return
                                user.friends.push {_id : docs[0]._id, name : param.name}
                                Db.update 'user', user._id, user, () =>
                                    res.send 200 # Change to render a proper page TODO
                            else
                                res.send 400
                    else
                        res.send 400 # Change to render a proper page TODO
        else
            err.push 'bad_name'
        if err.length > 0
            err = JSON.stringify err
            console.log err
            res.send 400 # Change to render a proper page TODO

    # Called for loging in a user.
    # Check sanity of all values and render the home page if any value is wrong.
    # if everything is ok, log the user in and redirect him into room.
    login : (req, res, next) =>
        param       = req.body
        console.log param
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
        req.session.uid = userData._id
        options =
            title   : Config.Voicious.Title
            login   : userData.name
            uid     : userData._id
        res.redirect "Dashboard"

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

    getFriendsArray : (userID, next) =>
        if userID?
            Db.get 'user', userID, (user) =>
                if user.friends? and user.friends.length isnt 0
                    i = 0
                    @requestUser user.friends, i, [], (friends) =>
                        list =
                            offline : []
                            online  : []
                            inroom  : []
                        j = 0
                        @requestFriendRoom friends, j, list, (list) =>
                            next list
                else
                    next {}
        else
            next {}

    getFriends : (req, res, next) =>
        param = req.params
        if param?
            if param.id?
                Db.get 'user', param.id, (user) =>
                    if user.friends? and user.friends.length isnt 0
                        i = 0
                        @requestUser user.friends, i, [], (friends) =>
                            list =
                                offline : []
                                online  : []
                                inroom  : []
                            j = 0
                            @requestFriendRoom friends, j, list, (list) =>
                                res.send list
                    else
                        res.send 400
            else
                res.send 400
        else
            res.send 400

    requestUser : (friends, offset, infos, callback) =>
        if friends[offset]?
            Db.get 'user', friends[offset]._id, (info) =>
                friend =
                    name    : info.name
                    rid : info.id_room
                    _id     : info._id

                infos.push friend
                @requestUser friends, offset + 1, infos, callback

        else
            callback infos

    requestFriendRoom : (friends, offset, list, callback) =>
        friend = friends[offset]
        if friend?
            console.log "Friend: ", friend
            if friend.rid?
                console.log "Friend 2: ", friend
                Db.getBy 'user', { id_room:friend.rid }, (docs) =>
                    if docs?
                        console.log "Docs: ", docs
                        if docs.length is 0
                            res.send 400
                        else
                            friend.nbInRoom = docs.length
                            list.inroom.push friend
                            @requestFriendRoom friends, offset + 1, list, callback
                    else
                        res.send 400
            else
                list.offline.push friend
                @requestFriendRoom friends, offset + 1, list, callback
        else
            callback list

    updateUserPassword : (req, res, next) =>
        param = req.body
        if param? and req.params.id?
            if param.password? and param.passwordconfirm?
                if param.password is param.passwordconfirm
                    Db.update 'user', req.params.id, {password:md5(param.password)}, () =>
                        res.send 200
                else
                    res.send 400
            else
                res.send 400
        else
            res.send 400

    updateUserMail : (req, res, next) =>
        param = req.body
        console.log param
        console.log req.params
        if param? and req.params.id?
            console.log "1"
            if param.mail?
                console.log "2"
                Db.find 'user', {'mail': param.mail}, (body) =>
                    console.log "3"
                    if not body? or body.length is 0
                        console.log "4"
                        Db.update 'user', req.params.id, {mail:param.mail}, () =>
                            res.send 200
                    else
                        res.send 400
            else
                res.send 400
        else
            res.send 400

    deleteFriend : (req, res, next) =>
        param = req.body
        if param? and param.name? and req.params.id?
            Db.get 'user', req.params.id, (user) =>
                if user?
                    if user.friends?
                        i = 0
                        list = []
                        if user.friends.length isnt 0
                            for friend of user.friends
                                if friend.name isnt user.name and user.friends.length isnt 1
                                    list.push friend
                                i++
                        Db.update 'user', req.params.id, {friends:list}, () =>
                            res.send 200
                    else
                        res.send 400
                else
                    res.send 400
        else
            res.send 400

exports.User    = new _User
exports.Routes  =
    post :
        '/register'     : exports.User.register
        '/login'        : exports.User.login
        '/quickLogin'   : exports.User.quickLogin
        '/quickJoin'    : exports.User.quickJoin
        '/join'         : exports.User.join
        '/friend'       : exports.User.addFriend

    get :
        '/create'       : exports.User.createRoom
        '/friends/:id'  : exports.User.getFriends

    put :
        '/user/mail/:id'        : exports.User.updateUserMail
        '/user/password/:id'    : exports.User.updateUserPassword

    delete:
        '/deleteFriend/:id'     : exports.User.deleteFriend
