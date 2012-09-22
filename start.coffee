fs = require('fs')

server = require('./server')
config = require('./config')

initLog = ->
        if not fs.existsSync(config.LOG_PATH)
                fs.mkdirSync(config.LOG_PATH)
                fd = fs.openSync(config.LOG_PATH + 'error.log', 'a')
                fs.closeSync(fd)
        else
           if not fs.existsSync(config.LOG_PATH + 'error.log')
                fd = fs.openSync(config.LOG_PATH + 'error.log', 'a')
                fs.closeSync(fd)

start = ->
        initLog()
        server.start(config.SERVER_PORT)

start()