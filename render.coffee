fs = require('fs')
jade = require('./modules/jade')

config = require('./config')
error = require('./errorHandler')

Renderer = {
        readJade: (file) ->
                try
                        fs.readFileSync(file, 'utf8')
                catch e
                        error = error.ErrorHandler.throwError(e, 500)
                        throw error

        render: (str, opts) ->
                try
                        tmp = jade.compile(str, opts)
                        tmp(opts)
                catch e
                        error = error.ErrorHandler.throwError(e, 500)
                        throw error

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