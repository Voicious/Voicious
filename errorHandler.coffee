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