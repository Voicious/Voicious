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

class Voicious
    constructor     : () ->
        @app            = do Express
        @configured     = no
        @connectedToDb  = no

    setAllRoutes    : () =>
        @app.get '/', (req, res) =>
            options =
                title   : 'Voicious'
            res.render 'home', options
        servicesNames   = Fs.readdirSync Config.Paths.Services
        for serviceName in servicesNames
            service = require '../services/' + serviceName
            if service.Routes?
                for method of service.Routes
                    if @app[method]?
                        for route of service.Routes[method]
                            @app[method] route, service.Routes[method][route]

    configure       : () =>
        if not @connectedToDb
            return
        @app.set 'port', Config.Port
        @app.set 'views', Config.Paths.Views
        @app.set 'view engine', 'jade'
        @app.use do Express.favicon
        @app.use Express.logger 'dev'
        @app.use do Express.bodyParser
        @app.use do Express.methodOverride
        @app.use Express.cookieParser 'your secret here'
        @app.use do Express.session
        @app.use @app.router
        @app.use Express.static Config.Paths.Webroot
        do @setAllRoutes
        @configured = yes

    start       : () =>
        do Database.connect
        Database.Db.on 'connected', () =>
            @connectedToDb  = yes
            PopulateDB.PopulateDB.populate () =>
                if not @configured
                    do @configure
                (Http.createServer @app).listen (@app.get 'port'), () =>
                    console.log "Server ready on port #{Config.Port}"

    end     : () ->
        do Database.close
        do @server.close

exports.Voicious = Voicious
