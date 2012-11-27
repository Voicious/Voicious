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

Service     = require './service'
Database    = require '../core/database'
User        = require './user'

class Session extends Service
    @default    : () ->
        return

class Model
    @_name      : 'session'
    @_schema    : {}
    @_instance  : undefined
    @get        : () ->
        if @instance == undefined
            @instance   = Database.createTable @_name, @_schema
            @instance.belongsTo User.Model,
                as          : 'user'
                foreignKey  : 'uid'
        @instance

exports.Session = Session
exports.Model   = do Model.get
