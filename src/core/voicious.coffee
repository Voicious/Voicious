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
PopulateDB = require './populateDB'

class Voicious
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
            PopulateDB.PopulateDB.populate (err) =>
                if err
                    throw err
                @server = http.createServer(onRequest).listen(Config.Port)
                logger.info "Server ready on port #{Config.Port}"
        catch e
            Database.close("physic")
            Database.close("memory")
            throw e

    end     : () ->
        Database.close("physic")
        Database.close("memory")
        do @server.close

exports.Voicious = Voicious