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

i18n        = require 'i18next'
nodemailer  = require 'nodemailer'
moment      = require 'moment'
md5         = require 'MD5'
fs          = require 'fs'
path = require 'path'

Config      = require '../common/config'
{Session}   = require './session'
{Errors}    = require '../common/errors'
{Token}     = require './token'
{Db}        = require '../common/' + Config.Database.Connector

class _Room
    # Initialize a nodemailer module and a list of modules
    # with default values.
    constructor : (@modulesList = [ 'userList' , 'tutorial', 'textChat', 'camera']) ->
        @transport = nodemailer.createTransport('Sendmail');
        @token  = Token

    # Render the room with the good translation and the list of modules stringified.
    renderRoom : (res, options, host) =>
        console.log "RENDER", options
        options.modules = JSON.stringify @modulesList
        options.audioFiles = fs.readdirSync path.join Config.Paths.Webroot, 'sounds', 'notification'
        res.render 'room', options

    # Create a new Room and check if the user is logged in.
    roomPage : (req, res, next) =>
        Db.get 'room', req.params.roomid, (body) =>
            if not body? or body.length is 0
                Errors.RenderNotFound req, res
            user          = req.currentUser
            options       =
                title   : Config.Voicious.Title
                login   : user.name
                uid     : user._id
                register: user._registered?
                rid     : req.params.roomid
                pjsHost : Config.Peerjs.Hostname.External
                pjsPort : Config.Peerjs.Port
            user.id_room = req.params.roomid
            Db.update 'user', user._id, user, () =>
                @token.createToken user._id, req.params.roomid, (token) =>
                    options.token = token
                    @renderRoom res, options, req.host

    # Retrieve the bug report entered by the user.
    # Send a mail if the nodemailer object find a sendmail in the server.
    # The bug report is stock into the collection/table bug.
    reportBug       : (req, res) =>
        @transport.sendMail({
            from    : "Voicious bugs<no-reply@voicious.com>"
            to      : 'voicious_2014@labeip.epitech.eu'
            subject : 'Bug Report ' + moment().format()
            text    : req.body.bug})
        Request.post {
            json    : req.body
            url     : "#{Config.Restapi.Url}/bug"
        }, (e, r, body) =>
            if e? or r.statusCode > 200
                throw new Errors.Error
            else
                res.send 200

    reportBug       : (req, res) =>
        @transport.sendMail {
            from    : "Voicious bugs<no-reply@voicious.com>"
            to      : 'voicious_2014@labeip.epitech.eu'
            subject : "Bug Report from #{req.body.from}" + do (do moment).format
            text    : req.body.bug
        }
        res.send 200

    # Create the new room and redirect the user inside.
    newRoom : (req, res, param) =>
        user = req.body
        param.owner = user._id
        Db.insert 'room', param, (newitem) =>
            res.redirect "/room/#{newitem._id}"

    redirectRoom : (req, res) =>
        if req.params.roomid?
            res.redirect "/?roomid=#{req.params.roomid}&hash=#jumpIn"

    shareroom : (req, res) =>
        @transport.sendMail {
            from : "Voicious<no-reply@voicious.com>"
            to : req.body.emails
            subject : "#{req.body.from}" + i18n.t("app.Room.ShareMail.MailSubject")
            text : i18n.t("app.Room.ShareMail.Hello") + "#{req.body.from}" + i18n.t("app.Room.ShareMail.Text") + "#{req.body.roomurl}"
        }
        res.send 200

exports.Room    = new _Room
exports.Routes  =
    get :
        '/room/:roomid' : (Session.ifUser.curry exports.Room.roomPage, exports.Room.redirectRoom)
    post :
        '/report'       : exports.Room.reportBug
        '/shareroom'    : exports.Room.shareroom
