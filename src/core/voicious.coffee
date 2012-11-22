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

http = require('http')

router = require('./router')
routeHandler = require('./routeHandler')
logger  = (require './logger').get 'voicious'
error = require('./errorHandler')

Config  = require './config'
Database = require './database'

class Voicious
    initDatabase: () ->
        @db = new Database.Database
        @db.createTable 'user', {
            name: { type: String, length: 255, index: true },
            mail: { type: String, length: 255 },
            password: { type: String, length: 255 },
            id_acl: { type: Number },
            id_role: { type: Number },
            c_date: { type: Date, default: Date.now },
            last_con: { type: Date }
            }
        @db.createTable 'role', {
            name: { type: String, length: 255, index: true},
            }
        @db.createTable 'acl', {
            name: { type: String, length: 255, index: true},
            }
        @db.flushTable (err) =>
            if err
                handler = new error.ErrorHandler
                e = handler.throwError(err, 500)
            else
                @db.insert 'role', {'name': role}  for role in Config.Roles
                @db.insert 'acl', {'name': acl} for acl in Config.Acl

    start   : () ->
        onRequest = (request, response) ->
            try
                    requestObject = router.Router.route(request, response)
                    logger.debug requestObject
                    template = routeHandler.RouteHandler.resolve(request, response, requestObject)
                    if template and template.template?
                            response.writeHead(200, {"Content-Type": "text/html"})
                            response.write(template.template)
                            response.end()
            catch e
                    if e.template?
                            response.writeHead(e.httpErrorCode, {"Content-Type": "text/html"})
                            response.write(e.template)
                    else
                            handler = new error.ErrorHandler
                            e = handler.throwError(e, 500)
                            response.writeHead(500, {"Content-Type": "text/html"})
                            response.write(e.template)
                    response.end()

        try
            @initDatabase()
            @server = http.createServer(onRequest).listen(Config.Port)
            logger.info "Server ready on port #{Config.Port}"
        catch e
            @db.close()
            throw e

    end     : () ->
        do @server.close

exports.Voicious = Voicious