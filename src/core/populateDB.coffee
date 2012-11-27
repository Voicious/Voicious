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

Config = require './config'
Database = require './database'

class PopulateDB
    @populate: (callback) ->
        User    = require '../services/user/user'
        Session = require '../services/session/session'
        Database.flushTable () =>
            u   = new User.Model
                name    : "Paul"
            User.Model.create u, () =>
                s   = new Session.Model
                s.user u.id
                Session.Model.create s, (err, session) =>
                    do callback

exports.PopulateDB = PopulateDB
