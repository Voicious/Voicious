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

jade = require('./render')
fileserve = require('./modules/node-static')

fileserver = new fileserve.Server()

route = (pathname, request, response) ->
    console.log "Requesting #{pathname}"
    if pathname? and pathname[0] is '/'
        if not pathname[1]
            routes['/'](request, response)
        else
            paths = pathname.split('/')
            if routes[paths[1]]?
                routes[paths[1]](request, response)
            else
                notFound(request, response)

home = (request, response) ->
    console.log "Accessing home"
    return {template: jade.Renderer.jadeRender('home.html', {name: "Voicious"})}

includes = (request, response) ->
    console.log "Downloading file"
    request.addListener('end', ->
        fileserver.serve(request, response, (e, res) ->
            if e and e.status is 404
                return {template: jade.Renderer.jadeRender('notFound.html')}))
notFound = (request, response) ->
    console.log "404 not found"
    return {template: jade.Renderer.jadeRender('notFound.html')}

routes = []
routes['/'] = home
routes['includes'] = includes

exports.home = home
exports.includes = includes
exports.route = route