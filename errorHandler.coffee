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

logger  = (require './logger').get 'voicious'

class ErrorHandler
        constructor: () ->
                @_errorObj = {}
                @_errorCode = {
                        404: "Not Found",
                        500: "Internal Server Error"}

                if not fs.existsSync(config.LOG_PATH)
                        fs.mkdirSync(config.LOG_PATH)
                @_fd = fs.openSync(config.LOG_PATH + 'error.log', 'a')

        log: () ->
                text = "";
                for key, value of @_errorObj
                        text += value
                logger.error @_errorObj.text

        renderError: () ->
                return {
                        httpErrorCode: @_errorObj.httpErrorCode,
                        template: jade.Renderer.jadeRender('error.html',
                        {
                         httpErrorCode: @_errorObj.httpErrorCode,
                         httpErrorMsg: @_errorObj.httpErrorMsg,
                         errno: if @_errorObj.errno then "Errno : #{@_errorObj.errno}" else "",
                         syscall: if @_errorObj.syscall then "Syscall : #{@_errorObj.syscall}" else "",
                         text: @_errorObj.text})}

        throwError: (text, httpErrorCode) ->
                @_errorObj.prompt = moment().format('MMMM Do YYYY, h:mm:ss a') + ' [Voicious] : '
                if typeof text is "object"
                        for key, value of text
                                if key is "errno" then @_errorObj.errno = "[#{value}] "
                                if key is "syscall" then @_errorObj.syscall = "(#{value}) "
                @_errorObj.text = text + "\n"
                this.log()
                @_errorObj.httpErrorCode = httpErrorCode
                @_errorObj.httpErrorMsg = @_errorCode[httpErrorCode]
                return this.renderError()

exports.ErrorHandler = ErrorHandler
