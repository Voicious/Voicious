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

url = require('url')

error = require('./errorHandler')

Router = {
        _requestObject: {
                path: [],
                args: {} }

        _regexp: new RegExp("^/([a-z0-9/\\._]*)(?:/argv[/]?)([a-z0-9/\\._]*)$|^/([a-z0-9/\\._]*)$", "i")

        route: (request, response) ->
                @_requestObject = {
                        path: [],
                        args: {} }
                @_pathname = url.parse(request.url)
                console.log "Requesting #{@_pathname.href}"
                @_method = request.method
                this.parseUrl()
                this.clean()
                return @_requestObject

        parseQueryUrl: () ->
                @_requestObject.path = @_pathname.pathname.toLowerCase().split('/')
                tmp = @_pathname.query.split('&')
                if tmp?
                        for value in tmp
                                tab = value.split('=')
                                @_requestObject.args[tab[0].toLowerCase()] = if tab[1]? then tab[1] else null
                else
                        tmp = @_pathname.query.split('=')
                        @_requestObject.args[tmp[0].toLowerCase()] = if tmp[1]? then tmp[1] else null

        parsePathUrl: () ->
                result = @_regexp.exec(@_pathname.pathname)
                if result? and result[1]? and result[2]?
                        @_requestObject.path = result[1].toLowerCase().split('/')
                        tmp = result[2].split('/')
                        for i in [0..tmp.length - 1] by 2
                                @_requestObject.args[tmp[i].toLowerCase()] = if tmp[i + 1]? then tmp[i + 1] else null
                else if result? and result[3]?
                        @_requestObject.path = result[3].toLowerCase().split('/')
                else
                        handler = new error.ErrorHandler
                        throw handler.throwError("This URL couldn't be resolved", 404)

        clean: () ->
                for value, key in @_requestObject.path when value is ''
                        @_requestObject.path.splice(key, 1)
                for key, value of @_requestObject.args when key is ''
                        delete @_requestObject.args[key]

        parseUrl: () ->
                if @_pathname.pathname is '/'
                        @_requestObject.path[0] = '/'
                else
                        if @_pathname.query?
                                this.parseQueryUrl()
                        else
                                this.parsePathUrl()
}

exports.Router = Router

###
    if pathname? and pathname[0] is '/'
        if not pathname[1]
            routes['/'](request, response)
        else
            paths = pathname.split('/')
            if routes[paths[1]]?
                routes[paths[1]](request, response)
            else
                notFound(request, response)

routes = []
routes['/'] = home
routes['includes'] = includes

exports.home = home
exports.includes = includes
###