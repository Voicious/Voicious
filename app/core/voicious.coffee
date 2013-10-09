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

Http    = require 'http'
Express = require 'express'
Fs      = require 'fs'
Path    = require 'path'
I18n	= require 'i18next'

Config       = require '../common/config'
{Errors}     = require '../common/errors'
{Db}         = require '../common/' + Config.Database.Connector
Ws = require '../ws/websocket.coffee'

SStore       = (require 'connect-' + Config.Voicious.Sessions.Connector) Express

# Just implement a _currying_ system, it will be used for routes.
Function.prototype.curry = () ->
    if arguments.length < 1
        return this
    _method = this
    args    = Array.prototype.slice.call arguments
    () ->
        _method.apply this, (args.concat Array.prototype.slice.call arguments)

# Main class
# It define the application, populate the database, load all the routes and launch the listenning.
class Voicious
    constructor     : () ->
        @app            = do Express
        @i18n  		    = I18n
        @configured     = no

    # Retrieve all routes from all services and register them in __Express__.
    # All routes are preprocessed by __Session.withCurrentUser__.
    setAllRoutes    : () =>
        # We can't require this before since it'll load its schema in the database
        {Session}       = require './session'
        @app.get '/', Session.withCurrentUser, (req, res) =>
            options =
                title           : (@app.get 'title'),
                hash            : '#jumpIn'
                login_email     : ''
                signup_email    : ''
                name            : ''
                roomid          : req.query.roomid || ''
            res.render 'home', options
        servicesNames   = Fs.readdirSync (Path.join Config.Paths.Root, 'core')
        for serviceName in servicesNames
            service = require './' + serviceName
            if service.Routes?
                for method of service.Routes
                    if @app[method]?
                        for route of service.Routes[method]
                            @app[method] route, Session.withCurrentUser, service.Routes[method][route]

    # Configure the __Express__ instance.
    configure       : () =>
        sstore = new SStore {
            db   : 'voicious_sessions'
            host : Config.Voicious.Sessions.Hostname.Internal
        }
        @i18n.init
            debug: true
            saveMissing: true
            resGetPath:  Path.join Config.Paths.Webroot, 'locales' ,'__lng__', '__ns__.json'
            lng: "en"
            fallbackLng: "en"
        @app.use @i18n.handle
        @app.set 'port', Config.Voicious.Port
        @app.set 'views', Config.Paths.Views
        @app.set 'view engine', 'jade'
        @app.set 'title', Config.Voicious.Title
        @app.use do Express.favicon
        @app.use Express.logger 'dev'      
        @app.use do Express.methodOverride
        @app.use do Express.bodyParser
        @app.use Express.cookieParser 'your secret here'
        @app.use Express.session {
            secret : 'your secret here',
            store  : sstore
        }
        @app.use @app.router
        @app.use Express.static Config.Paths.Webroot
        @app.use (require 'connect-assets') src : Config.Paths.Webroot
        do @setAllRoutes

        @app.use (req, res, next) =>
            Errors.RenderNotFound req, res
        @app.use (err, req, res, next) =>
            console.error err
            Errors.RenderError req, res

        @i18n.registerAppHelper @app
        @configured = yes

    # Main function
    # It'll populate the database, fetch the configuration and launch the listenning.
    start       : () =>
        Db.connect () =>
            if not @configured
                do @configure
            process.on 'SIGINT', @end
            server = (Http.createServer @app).listen (@app.get 'port'), () =>
                console.log "Server ready on port #{@app.get 'port'}"
            (new Ws.Websocket).start (server)

    # A callback closing the database before exiting.
    end     : () ->
        console.log "Exiting..."
        do process.exit

do (new Voicious).start
