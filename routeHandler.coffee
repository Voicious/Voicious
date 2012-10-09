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

fileserve = require('./modules/node-static')

jade = require('./render')
config = require('./config')

RouteHandler = {
        _fileserver: new fileserve.Server()

        resolve: (request, response, requestObject) ->
                if requestObject.path[0]?
                        if requestObject.path[0] == "/"
                                return {template: jade.Renderer.jadeRender('home.html', {name: "Voicious"})}
                        if requestObject.path[0] == "includes"
                                request.addListener('end', =>
                                        @_fileserver.serve(request, response, (e, res) ->
                                                if e? and e.status is 404
                                                        response.writeHead(e.status, e.headers)
                                                        response.end()))
}

exports.RouteHandler = RouteHandler