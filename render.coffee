fs = require('fs')
jade = require('./modules/jade')

config = require('./config')
error = require('./errorHandler')

Renderer = {
        readJade: (file) ->
                try
                        fs.readFileSync(file, 'utf8')
                catch e
                        handler = new error.ErrorHandler
                        throw handler.throwError(e, 500)

        render: (str, opts) ->
                try
                        tmp = jade.compile(str, opts)
                        tmp(opts)
                catch e
                        handler = new error.ErrorHandler
                        throw handler.throwError(e, 500)

        jadeRender: (path, options) ->
                file = config.TPL_PATH + path
                def_opts = {
                        pretty: true,
                        filename: file}
                for opts of options
                        def_opts[opts] = options[opts]
                res = this.render(this.readJade(file), def_opts)
}

exports.Renderer = Renderer