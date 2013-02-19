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

class Translator
    constructor         : () ->

    getTrans            : (host, view) ->
        if host isnt undefined
            location = host.split '.'
            location = location[location.length - 1]
            if location is 'fr'
                return (require "../trans/fr/#{view}").transDef
        return (require "../trans/en/#{view}").transDef

exports.Translator = new Translator
