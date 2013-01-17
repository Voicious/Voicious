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

Http        = require 'http'
Express     = require 'express'
{Schema}    = require 'jugglingdb'
Fs          = require 'fs'
Path        = require 'path'

Config      = require '../common/config'

class Api
    constructor     : () ->
        @app            = do Express
        @db             = new Schema 'mongodb', {
            connector   : 'mongodb'
            database    : 'testdb'
        }
        @models         = []
        @configured     = false
    
    defineGet       : (model) =>
        @app.get '/api/' + model, (req, res) =>
            # TODO set filters, expands etc.
            if req.query
                objs = {}
                for k, v of req.query
                    objs[k] = v
                try
                    @db.models[model].all {where: objs}, (err, objs) =>
                        if objs?
                            res.json objs
                        else
                            res.json []
                catch e
                    res.send 400
            else
                @db.models[model].all (err, all) =>
                    res.json all
        @app.get '/api/' + model + '/:id', (req, res) =>
            try
                @db.models[model].find req.params.id, (err, obj) =>
                    if obj?
                        res.json obj
                    else
                        res.send 404
            catch e
                res.send 400

    defineDelete    : (model) =>
        @app.delete '/api/' + model + '/:id', (req, res) =>
            try
                @db.models[model].find req.params.id, (err, obj) =>
                    if obj?
                        obj.destroy () =>
                            res.send 200
                    else
                        res.send 404
            catch e
                res.send 400

    updateOrCreate  : (model, req, res) =>
        if not req.body.id or req.body.id is req.params.id
            obj = new @models[model] req.body
            obj.isValid (valid) =>
                if valid
                    @models[model].updateOrCreate req.body, (err, inst) =>
                        res.json inst
                else
                    res.send 400
        else
            res.send 400

    definePost      : (model) =>
        @app.post '/api/' + model, (req, res) =>
            @updateOrCreate model, req, res

    definePut       : (model) =>
        @app.put '/api/' + model + '/:id', (req, res) =>
            @updateOrCreate model, req, res

    defineAllRoutes : () =>
        ressources  = []
        for model of @db.models
            ressources.push model
            @defineGet model
            @definePost model
            @defineDelete model
            @definePut model
        @app.get '/api', (req, res) => res.json ressources
        @app.options /.*/, (req, res) => res.send 200

    defineAllModels : () =>
        # TODO replace with path variable
        modelsPath  = Path.join __dirname, '../models'
        modelsNames = Fs.readdirSync modelsPath
        for modelName in modelsNames
            if (modelName.split '.')[1] == "js"
                {
                    ModelDef
                    AfterModelDef
                }   = require '../models/' + modelName
                name            = (modelName.split '.')[0]
                @models[name]   = @db.define name, ModelDef
                AfterModelDef @models[name]

    configure       : () =>
        @app.set 'port', Config.RestAPI.Port
        @app.use Express.logger 'dev'
        @app.use do Express.bodyParser
        @app.use do Express.methodOverride
        @app.use (req, res, next) ->
            if req.headers.origin?
                if req.headers.origin in Config.RestAPI.AllowedHosts or
                '*' in Config.RestAPI.AllowedHosts
                    res.set 'Access-Control-Allow-Methods', 'PUT, DELETE'
                    res.set 'Access-Control-Allow-Origin', req.headers.origin
            do next
        @app.use @app.router
        do @defineAllModels
        do @defineAllRoutes
        @configured = true

    start       : () =>
        @db.on 'connected', () =>
            do @configure if not @configured
            (Http.createServer @app).listen (@app.get 'port'), () =>
                console.log "Server ready on port #{@app.get 'port'}"

do (new Api).start
