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

Logger  = require './logger'

##
# Voicious configuration file
# Don't forget to recompile it after any changes
##

exports.SERVER_PORT = 4242
exports.LOG_PATH = __dirname + '/log/'
exports.TPL_PATH = __dirname + '/includes/tpl/'

exports.PATH_ROUTES = [
        ["includes"],
        ["modules", "user"]
]

exports.LOGLEVEL    = Logger.WARN
