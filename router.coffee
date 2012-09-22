jade = require('./render')
fileserve = require('./modules/node-static')

fileserver = new fileserve.Server()

route = (pathname, request, response) ->
    console.log "Requesting #{pathname}"
    if pathname? and pathname[0] is '/'
        if not pathname[1]
            routes['/'](request, response)
        else
            paths = pathname.split('/')
            if routes[paths[1]]?
                routes[paths[1]](request, response)
            else
                notFound(request, response)

home = (request, response) ->
    console.log "Accessing home"
    return {template: jade.Renderer.jadeRender('home.html', {name: "Voicious"})}

includes = (request, response) ->
    console.log "Downloading file"
    request.addListener('end', ->
        fileserver.serve(request, response, (e, res) ->
            if e and e.status is 404
                return {template: jade.Renderer.jadeRender('notFound.html')}))
notFound = (request, response) ->
    console.log "404 not found"
    return {template: jade.Renderer.jadeRender('notFound.html')}

routes = []
routes['/'] = home
routes['includes'] = includes

exports.home = home
exports.includes = includes
exports.route = route