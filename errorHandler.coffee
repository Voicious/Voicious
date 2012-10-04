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
fs = require('fs')
moment = require('./modules/moment')

config = require('./config')
jade = require('./render')

class ErrorHandler
        constructor: () ->
                @errorObj = {}
                @errorCode = {500: "Internal Server Error"}
                if not fs.existsSync(config.LOG_PATH)
                        fs.mkdirSync(config.LOG_PATH)
                @fd = fs.openSync(config.LOG_PATH + 'error.log', 'a')

        log: () ->
                text = "";
                for key, value of @errorObj
                        text += value
                fs.writeSync(@fd, text, 0, text.length, null)
                fs.closeSync(@fd)

        renderError: () ->
                return {
                        httpErrorCode: @errorObj.httpErrorCode,
                        template: jade.Renderer.jadeRender('error.html',
                        {
                         httpErrorCode: @errorObj.httpErrorCode,
                         httpErrorMsg: @errorObj.httpErrorMsg,
                         errno: @errorObj.errno,
                         syscall: @errorObj.syscall,
                         text: @errorObj.text
                        })
                        }

        throwError: (text, httpErrorCode) ->
                @errorObj.prompt = moment().format('MMMM Do YYYY, h:mm:ss a') + ' [Voicious] : '
                if typeof text is "object"
                        for key, value of text
                                if key is "errno" then @errorObj.errno = "[#{value}] "
                                if key is "syscall" then @errorObj.syscall = "(#{value}) "
                @errorObj.text = text + "\n"
                this.log()
                @errorObj.httpErrorCode = httpErrorCode
                @errorObj.httpErrorMsg = @errorCode[httpErrorCode]
                return this.renderError()

exports.ErrorHandler = ErrorHandler