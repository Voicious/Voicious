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
error = require('./errorHandler')

RouteHandler = {
        _fileserver: new fileserve.Server()

        _routes: config.PATH_ROUTES

        resolve: (request, response, requestObject) ->
                if requestObject.path[0]?
                        if requestObject.path[0] == "/"
                                return {template: jade.Renderer.jadeRender('home.html', {name: "Voicious"})}
                        if requestObject.path[0] == config.STATIC_FILES_PATH
                                request.addListener('end', =>
                                        @_fileserver.serve(request, response, (e, res) ->
                                                if e? and e.status is 404
                                                        response.writeHead(e.status, e.headers)
                                                        response.end()))
                        else
                                for path in @_routes
                                        moduleExist = true
                                        for file, key in path
                                                if file isnt requestObject.path[key]
                                                        moduleExist = false
                                                        break
                                        if moduleExist is true
                                                if requestObject.path[key]?
                                                        method = requestObject.path[key]
                                                        requestObject.path.pop()
                                                        object = requestObject.path.join('/')
                                                        console.log "Calling class method \"#{method}\" of object #{object}"
                                                        callingObject = require("./" + "#{object}")
                                                        methodExist = false
                                                        for parent, value of callingObject
                                                                for funcName, funcValue of value when funcName is method
                                                                        func = funcValue.toString()
                                                                        paramName = func.slice(func.indexOf('(') + 1, func.indexOf(')')).match(/([^\s,]+)/g)
                                                                        params = []
                                                                        i = 0
                                                                        for k, v of requestObject.args
                                                                                if not paramName[i]? or k isnt paramName[i]
                                                                                        handler = new error.ErrorHandler
                                                                                        throw handler.throwError("[Error] : unknown parameter \"#{k}\" in function \"#{method}\" ", 400)
                                                                                params.push(v)
                                                                                i++
                                                                        callingObject[parent][funcName].apply(null, params)
                                                                        methodExist = true
                                                        if methodExist is false
                                                                handler = new error.ErrorHandler
                                                                throw handler.throwError("[Error] : method \"#{method}\" of class \"#{parent}\" is undefined", 404)
                                                else
                                                        object = requestObject.path.join('/')
                                                        console.log "Calling default class method of object #{object}"
                                                break
                                if moduleExist is false
                                        handler = new error.ErrorHandler
                                        throw handler.throwError("[Error] : #{requestObject.path.join('/')} is undefined", 404)
}

exports.RouteHandler = RouteHandler