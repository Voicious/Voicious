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

Config  = require '../common/config'

class Errors
    @NotFound : (msg = "404 Not Found") ->
        @name   = 'NotFound'
        Error.call this, msg
        Error.captureStackTrace this, arguments.callee

    @Error : (msg) ->
        @name   = 'InternalServerError'
        Error.call this, msg
        Error.captureStackTrace this, arguments.callee

    @RenderNotFound : (req, res) ->
        res.status 404
        if req.url is "/browser"
            options =
                status      : "Oops"
                statusText  : "Wrong browser"
                errorMsg    : "> Looks like you're using a browser that does not support WebRTC.<br />> Sorry, you can only use Google Chrome for the current beta."
        else
            options =
                status      : "404"
                statusText  : "not_found"
                errorMsg    : "> Oops !<br />> Looks like the page you are looking for doesn't exist.<br />> Sorry."
        options.title = Config.Voicious.Title + " | " + options.status + " " + options.statusText
        res.render 'error.jade', options

    @RenderError : (req, res) ->
        res.status 500
        options =
            status      : "500"
            statusText  :"server_error"
            errorMsg    : "> Oops !<br />> Looks like something went wrong.<br />> Sorry."
        options.title = Config.Voicious.Title + " | " + options.status + " " + options.statusText
        res.render 'error.jade', options


exports.Errors  = Errors
