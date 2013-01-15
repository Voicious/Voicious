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
{User}          = require './user'
Config          = require '../common/config'

class _Session
    constructor     : () ->

    # Middleware which load the current user informations in __req.currentUser__
    withCurrentUser : (req, res, next) =>
        req.currentUser = undefined
        if req.session? and req.session.uid?
            Request.get "#{Config.RestAPI.Url}/user/#{req.session.uid}", (e, r, u) =>
                req.currentUser = JSON.parse u
                do next
        else
            do next

    # Middleware-like function which will call it's __next__ argument if __req.currentUser__ exists  
    # It'll redirect to _'/'_ if not
    ifUser          : (next, req, res) =>
        if req.currentUser
            next req, res
        else
            res.redirect '/'

exports.Session = new _Session
