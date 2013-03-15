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
Https       = require 'https'
Express     = require 'express'
{Schema}    = require 'jugglingdb'
Fs          = require 'fs'
Path        = require 'path'

Config      = require '../common/config'

# The REST API request the database.
class Api
    constructor     : () ->
        @app            = do Express
        @db             = new Schema Config.Restapi.Database.Connector, {
            connector   : Config.Restapi.Database.Connector
            database    : Config.Restapi.Database.Database
        }
        @models         = []
        @configured     = false

    # Get informations from the database with a model and by id.
    defineGet       : (model) =>
        @app.get '/api/' + model, (req, res) =>
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

    # Delete informations from the database with a model and by id. 
    defineDelete    : (model) =>
        @app.del '/api/' + model + '/:id', (req, res) =>
            try
                @db.models[model].find req.params.id, (err, obj) =>
                    if obj?
                        obj.destroy () =>
                            res.send 200
                    else
                        res.send 404
            catch e
                res.send 400

    # Update or create informations from the database with a model and by id. 
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

    # Define post function.
    definePost      : (model) =>
        @app.post '/api/' + model, (req, res) =>
            @updateOrCreate model, req, res

    # Define put function.
    definePut       : (model) =>
        @app.put '/api/' + model + '/:id', (req, res) =>
            @updateOrCreate model, req, res

    # Set all routes for all the models.
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

    # Define all the models.
    defineAllModels : () =>
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

    # Initialize REST API context.
    configure       : () =>
        @app.set 'port', Config.Restapi.Port
        @app.use Express.logger 'dev'
        @app.use do Express.bodyParser
        @app.use do Express.methodOverride
        @app.use (req, res, next) ->
            if req.headers.origin?
                if req.headers.origin in Config.Restapi.AllowedHosts or
                '*' in Config.Restapi.AllowedHosts
                    res.set 'Access-Control-Allow-Methods', 'PUT, DELETE'
                    res.set 'Access-Control-Allow-Origin', req.headers.origin
            do next
        @app.use @app.router
        do @defineAllModels
        do @defineAllRoutes
        @configured = true

    # Start the REST API services.
    start       : () =>
        @db.on 'connected', () =>
            do @configure if not @configured
            if Config.Restapi.Ssl.Enabled
                ssl =
                    key  : do (Fs.readFileSync (Path.join Config.Paths.Config, Config.Restapi.Ssl.Key)).toString
                    cert : do (Fs.readFileSync (Path.join Config.Paths.Config, Config.Restapi.Ssl.Certificate)).toString
                (Https.createServer ssl, @app).listen (@app.get 'port'), () =>
                    console.log "Server ready on port #{@app.get 'port'} (SSL)"
            else
                (Http.createServer @app).listen (@app.get 'port'), () =>
                    console.log "Server ready on port #{@app.get 'port'}"


do (new Api).start
