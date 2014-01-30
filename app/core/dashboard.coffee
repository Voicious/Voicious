###

Copyright (c) 2011-2014  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

{Errors}        = require '../common/errors'
Config          = require '../common/config'
{Db}            = require '../common/' + Config.Database.Connector

class _Dashboard
    constructor : () ->

    dashboard : (req, res, next) =>
        userData = req.currentUser
        if !userData.registered?
            res.redirect "/"
        else
            options =
                title   : Config.Voicious.Title
                login   : userData.name
                uid     : userData._id
            {User}  = require './user'
            User.getFriendsArray userData._id, (friendsList) ->
                options.online = friendsList.online
                options.offline = friendsList.offline
                options.inroom = friendsList.inroom
                console.log JSON.stringify options
                res.render "dashboard", options

exports.Dashboard  = new _Dashboard
exports.Routes  =
    get :
        '/dashboard'    : exports.Dashboard.dashboard