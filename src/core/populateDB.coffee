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

Error = require('./errorHandler')
Config = require './config'
Database = require './database'

class PopulateDB
    @populate: (callback) ->
        Database.connect 'physic', Config.Database
        Database.createTable 'physic', 'user', {
            name: { type: String, length: 255, index: true },
            mail: { type: String, length: 255 },
            password: { type: String, length: 255 },
            id_acl: { type: Number },
            id_role: { type: Number },
            c_date: { type: Date, default: Date.now },
            last_con: { type: Date }
            }
        Database.flushTable 'physic', callback
        Database.get 'physic', 'jkdghsksruksu'

exports.PopulateDB = PopulateDB0