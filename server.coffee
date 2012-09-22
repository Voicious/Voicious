http = require('http')
url = require('url')
router = require('./router')

start = (port) ->
    onRequest = (request, response) ->
        try
                pathname = url.parse(request.url).pathname
                template = router.route(pathname, request, response)
                if template.template?
                    response.writeHead(200, {"Content-Type": "text/html"})
                    response.write(template.template)
                    response.end()
        catch e
                response.writeHead(200, {"Content-Type": "text/html"})
                response.write(e.template)
                response.end()

    http.createServer(onRequest).listen(port)
    console.log "Server ready on port #{port}"

exports.start = start
