http = require('http')
fs = require('fs')
moment = require('./modules/moment')

config = require('./config')
jade = require('./render')

ErrorHandler = {
        errorObj: {}
        initLog: ->
                if not fs.existsSync(config.LOG_PATH)
                        fs.mkdirSync(config.LOG_PATH)
                return fs.openSync(config.LOG_PATH + 'error.log', 'a')

        log: () ->
                fd = this.initLog()
                text = "";
                for key, value of this.errorObj
                        text += value
                fs.writeSync(fd, text, 0, text.length, null)
                fs.closeSync(fd)

        renderError: () ->
                return {requestCode: this.errorObj.httpError, template: jade.Renderer.jadeRender('error.html', {httpError: this.errorObj.httpError, errno: this.errorObj.errno, syscall: this.errorObj.syscall, text: this.errorObj.text})}

        throwError: (text, httpError) ->
                this.errorObj.prompt = moment().format('MMMM Do YYYY, h:mm:ss a') + ' [Voicious] : '
                if typeof text is "object"
                        for key, value of text
                                if key is "errno" then this.errorObj.errno = "[#{value}] "
                                if key is "syscall" then this.errorObj.syscall = "(#{value}) "
                this.errorObj.text = text + "\n"
                this.log()
                this.errorObj.httpError = httpError
                return this.renderError()
}

exports.ErrorHandler = ErrorHandler