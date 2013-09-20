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


class NotificationManager
    # Initialize the Notification Manager and set the callbacks for the Event Manager.
    constructor     : (@emitter) ->
        @emitter.on 'notif.text.ok', (event, data) =>
            @textNotif yes, data
        @emitter.on 'notif.text.ko', (event, data) =>
            @textNotif no, data
        @emitter.on 'notif.audio', (event, data) =>
            @audioNotif data.name

    textNotif : (type, data) =>
        cla = if type then 'success' else 'error'
        icon = if type then 'icon-check-sign' else 'icon-remove-sign'
        n = """<div class='notification-wrapper none'>
                    <div class='notification notification-#{cla}'>
                        <i class='#{icon} icon-large'></i>
                        <span class='notification-content'>#{data.text}</span>
                    </div>
                </div>"""
        n = ($ n)
        ($ 'body').append n
        ((n.fadeIn 600).delay 3000).fadeOut 1000, () =>
            do n.remove

    audioNotif : (name) =>
        if window.Voicious.focus is false
            do $("audio[name^='" + name + "']")[0].play

if window.Voicious?
    window.Voicious.NotificationManager   = NotificationManager
