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

Http    = require 'http'
Express = require 'express'
Fs      = require 'fs'

Config      = require './config'
Database    = require './database'
PopulateDB  = require './populateDB'
{Errors}    = require './errors'

# Just implement a _currying_ system, it will be used for routes
Function.prototype.curry = () ->
    if arguments.length < 1
        return this
    _method = this
    args    = Array.prototype.slice.call arguments
    () ->
        _method.apply this, (args.concat Array.prototype.slice.call arguments)

# Main class  
# It define the application, populate the database, load all the routes and launch the listenning
class Voicious
    constructor     : () ->
        @app            = do Express
        @configured     = no
        @connectedToDb  = no

    # Retrieve all routes from all services and register them in __Express__  
    # All routes are preprocessed by __Session.withCurrentUser__
    setAllRoutes    : () =>
        # We can't require this before since it'll load its schema in the database
        {Session}       = require '../services/session'
        @app.get '/', Session.withCurrentUser, (req, res) =>
            options =
                title   : (@app.get 'title'),
                hash    : ''
                email   : ''
                name    : ''
            res.render 'home', options
        servicesNames   = Fs.readdirSync Config.Paths.Services
        for serviceName in servicesNames
            service = require '../services/' + serviceName
            if service.Routes?
                for method of service.Routes
                    if @app[method]?
                        for route of service.Routes[method]
                            @app[method] route, Session.withCurrentUser, service.Routes[method][route]
        @app.all /^(?!\/public)\/*/, (req, res) =>
            throw new Errors.NotFound

    # Configure the __Express__ instance
    configure       : () =>
        if not @connectedToDb
            return
        @app.set 'port', Config.Port
        @app.set 'views', Config.Paths.Views
        @app.set 'view engine', 'jade'
        @app.set 'title', 'voıċıoųs'
        @app.use do Express.favicon
        @app.use Express.logger 'dev'
        @app.use do Express.bodyParser
        @app.use do Express.methodOverride
        @app.use Express.cookieParser 'your secret here'
        @app.use do Express.session
        @app.use @app.router
        @app.use Express.static Config.Paths.Webroot
        do @setAllRoutes
        @app.use (err, req, res, next) =>
            options = {}
            if err instanceof Errors.NotFound
                res.status 404
                options.status      = "404"
                options.statusText  = "not_found"
                options.errorMsg    = "> Oops !<br />> Looks like the page you are looking for doesn't exist.<br />> Sorry."
            else
                res.status 500
                options.status      = "500"
                options.statusText  = "server_error"
            options.title   = (@app.get 'title') + " | " + options.status + " " + options.statusText
            res.render 'error.jade', options
        @configured = yes

    # Main function  
    # It'll populate the database, fetch the configuration and launch the listenning  
    # It also add a listener which properly close the database on _SIGINT_
    start       : () =>
        do Database.connect
        Database.Db.on 'connected', () =>
            @connectedToDb  = yes
            PopulateDB.PopulateDB.populate () =>
                if not @configured
                    do @configure
                process.on 'SIGINT', @end
                (Http.createServer @app).listen (@app.get 'port'), () =>
                    console.log "Server ready on port #{Config.Port}"

    # A callback closing the database before exiting
    end     : () ->
        console.log "Exiting..."
        do Database.close
        do process.exit

exports.Voicious = Voicious
