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

class _ResponseHandler
    setResponseObject: (response) ->
        @response = response

    sendResponse: (code, template, responseParams) ->
        @response.writeHead code, {"Content-Type": "text/html"}
        for param, value in responseParams?
            @response.setHeader param, value
        @response.write template
        @response.end()

class ResponseHandler
    @_instance  = undefined
    @get        : () ->
        @_instance  ?= new _ResponseHandler

r   = do ResponseHandler.get
for key of r
    exports[key]    = r[key]
