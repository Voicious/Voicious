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

Vows        = require 'vows'
Assert      = require 'assert'
Http        = require 'http'
Config      = (require '../www/lib/config')

api         =
    checkStatus     : (code) ->
        return (res, e) ->
            Assert.equal res.statusCode, code
            return

    respondsWith    : (code) ->
        context =
            topic   : () ->
                options =
                    host    : 'localhost'
                    port    : Config.SERVER_PORT
                    path    : (@context.name.split ' ')[1]
                    method  : (@context.name.split ' ')[0]
                r       = Http.request options, @callback
                do r.end
                return
        context['Should respond ' + code]   = api.checkStatus code
        return context

((Vows.describe 'Voicious').addBatch
    'GET /'     : api.respondsWith 200
).export module
