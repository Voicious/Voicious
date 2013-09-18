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

Moment      = require 'moment'

Config      = require '../common/config'
{Session}   = require './session'
{Errors}    = require '../common/errors'

class _Stats
    constructor: () ->

    # Render the stats page.
    renderStats : (res, options) =>
        res.render 'stats', options

    # Create a new document into the collection "stat".
    # Set the nb_user_tmp to 1.
    insertNewDate : (req, res, body, callback, timestamp) =>
        Request.post {
            json    :
                c_date : timestamp
                nb_user_tmp : 1
            url     : "#{Config.Restapi.Url}/stat"
        }, (e, r, body) =>
            if e? or r.statusCode > 200
                Errors.RenderNotFound req, res
            else
                callback req, res

    # Increment the nb_user_tmp into the stat collection for the given id from the body.
    updateNbrTmpUser : (req, res, body, callback) =>
        body = body[0]
        body.nb_user_tmp += 1
        Request.put {
            json    : body
            url     : "#{Config.Restapi.Url}/stat/#{body.id}"
        }, (e, r, body) =>
            if e? or r.statusCode > 200
                Errors.RenderNotFound req, res
            else
                callback req, res

    # Create or update the number of temporary user daily.
    countTmpUser : (req, res, callback) =>
        date = Moment().format "YYYY-MM-DD"
        timestamp = String(do (new Date(date)).getTime)
        Request.get "#{Config.Restapi.Url}/stat?c_date=#{timestamp}", (e, r, body) =>
            if e? or r.statusCode > 200
                Errors.RenderNotFound req, res
            else
                body = JSON.parse body
                if body.length is 0
                    @insertNewDate req, res, body, callback, timestamp
                else
                    @updateNbrTmpUser req, res, body, callback

    # Parse the number of room created per Day.
    getNumberOfRoomsPerDay: (req, res, body) =>
        body = JSON.parse body
        data = {}
        for rooms in body
            date = Moment.unix rooms.c_date / 1000
            key = date.format "YYYY-MM-DD"
            timestamp = do (new Date(key)).getTime
            if data[timestamp]?
                data[timestamp] = data[timestamp] += 1
            else
                data[timestamp] = 1
        tmp = []
        for timestamp, nb of data
            tmp.push [Number(timestamp), nb]
        return tmp

    # Get the number of temporary user created per Day.
    # Return a array of array in the form [[2013-03-12,42], [2013-03-13,12]].
    getNumberOfTmpUsersPerDay: (req, res, body) =>
        body = JSON.parse body
        data = []
        for users in body
            data.push [Number(users.c_date), users.nb_user_tmp]
        return data

    # Get all the values for the graphs and render the stats page if no errors occurs.
    statsPage : (req, res) =>
        Request.get "#{Config.Restapi.Url}/room", (e, r, body) =>
            if e? or r.statusCode > 200
                Errors.RenderNotFound req, res
            else
                chart1 = JSON.stringify @getNumberOfRoomsPerDay req, res, body
                Request.get "#{Config.Restapi.Url}/stat", (e, r, body) =>
                    if e? or r.statusCode > 200
                        Errors.RenderNotFound req, res
                    else
                        chart2 = JSON.stringify @getNumberOfTmpUsersPerDay req, res, body
                        options =
                            title           : 'Voicious'
                            chart1          : chart1
                            chart2          : chart2
                        @renderStats res, options

exports.Stats   = new _Stats
exports.Routes  =
    get :
        '/stats' : exports.Stats.statsPage
