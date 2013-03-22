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

Config          = require '../common/config'
{Translator}    = require './trans'

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
            if loc is 'fr'
                options.statusText = "Mauvais navigateur"
                options.errorMsg = "> Il semblerait que votre navigateur ne support pas WebRTC.<br />> Désolé, vous pouvez seulement utiliser Google chrome pour la béta actuelle."
            else
                options.errorMsg = "> Looks like you're using a browser that does not support WebRTC.<br />> Sorry, you can only use Google Chrome for the current beta."
                options.statusText = "Wrong browser"
        else
            options =
                status          : "404"
                statusText      : "not_found"
            if loc is 'fr'
                options.errorMsg  = "> Oups !<br />> La page que vous recherchez n'existe pas.<br />> Désolé."
            else
                options.errorMsg  = "> Oops !<br />> Looks like the page you are looking for doesn't exist.<br />> Sorry."
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
        if loc is 'fr'
            options.errorMsg = "> Oups !<br />> Une erreur s'est produite.<br />> Désolé."
        else
            options.errorMsg = "> Oops !<br />> Looks like something went wrong.<br />> Sorry."
        options.title = Config.Voicious.Title + " | " + options.status + " " + options.statusText
        options.year = do (new Date()).getFullYear
        res.render 'error.jade', options


exports.Errors  = Errors
