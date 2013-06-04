###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

md5         = require 'MD5'

Config      = require '../common/config'
{Db}        = require './' + Config.Database.Connector

# Generate a unique token.
class _Token
        constructor : () ->

        # Create the unique token and add it into the dataBase.
        createToken : (clientId, roomId, callback) =>
            data =
                id_room   : roomId
                id_client : clientId
            Db.insert 'token', data, (newitem) =>
                callback newitem._id

        # Delete a token from database.
        deleteToken : (token) =>
            Db.delete 'token', token, () =>

exports.Token   = new _Token
