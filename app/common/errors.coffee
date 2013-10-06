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

i18n            = require 'i18next' 
Config          = require './config'
{Translator}    = require '../core/trans'

class Errors
    # Configure 404.
    @NotFound : (msg = "404 Not Found") ->
        @name   = 'NotFound'
        Error.call this, msg
        Error.captureStackTrace this, arguments.callee

    # Configure Internal Server Error.
    @Error : (msg) ->
        @name   = 'InternalServerError'
        Error.call this, msg
        Error.captureStackTrace this, arguments.callee

    # Render the Error page with a 404.
    # Also used when a wrong browser is use.
    # Set the right message and render the error page.
    @RenderNotFound : (req, res) ->
        loc = Translator.getDomain req.host
        res.status 404
        if req.url is "/browser"
            options =
                status          : "Oops"
            options.errorMsg = i18n.t("app.Errors.WrongBrowser.Message")
            options.statusText = i18n.t("app.Errors.WrongBrowser.Status")
        else
            options =
                status          : "404"
                statusText      : "not_found"
            options.errorMsg  = i18n.t("app.Errors.404")
        options.title = Config.Voicious.Title + " | " + options.status + " " + options.statusText
        options.year = do (new Date()).getFullYear
        res.render 'error.jade', options

    # Set the right message and render the internal error page.
    @RenderError : (req, res) ->
        loc = Translator.getDomain req.host
        res.status 500
        options =
            status              : "500"
            statusText          : "server_error"
        options.errorMsg = i18n.t("app.Errors.500")
        options.title = Config.Voicious.Title + " | " + options.status + " " + options.statusText
        options.year = do (new Date()).getFullYear
        res.render 'error.jade', options


exports.Errors  = Errors
