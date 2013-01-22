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

Request     = require 'request'
Config      = require '../common/config'

class _Token
        constructor : () ->

        createToken : (clientId, roomId, callback) ->
            Request.post {
                json    : {
                    id_room   : roomId
                    id_client : clientId
                }
                url     : "#{Config.Restapi.Url}/token"
            }, (e, r, body) =>
                if e? or r.statusCode > 200
                    throw new Errors.Error
                else
                    callback body.id
        
        deleteToken : (token) ->
            Request.del "#{Config.Restapi.Url}/token/#{token}", (e, r, data) =>
                if e? or r.statusCode > 200
                  Errors.Error error "Failed to delete token"

exports.Token   = new _Token
