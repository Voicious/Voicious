###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class UserList extends Module
    # The user list contain all the informations of the guests in the room.
    constructor     : (emitter) ->
        super emitter
        @jqContainer = ($ 'ul#feeds')
        @columns     = 1
        @users       = { }
        @users[window.Voicious.currentUser.uid] = window.Voicious.currentUser
        do @configureEvents
        do @display
        ($ window).on 'resize', () =>
            do @updateColumns

    configureEvents     : () =>
        @emitter.on 'peer.list', @fill
        @emitter.on 'peer.create', (event, user) =>
            @update 'create', user
        @emitter.on 'peer.remove', (event, user) =>
            @update 'remove', user
        @emitter.on 'stream.display', (event, video) =>
            uid = ($ video).attr 'rel'
            @users[uid].video = video
            ($ "li#video_#{uid}").append video

    # Fill the user list with new users.
    fill            : (event, data) =>
        for user in data.peers
            @users[user.id] = { name : user.name , uid : user.id }
        do @display

    # Update the user list by creating or removing a user from the list.
    update          : (event, user) =>
        switch event
            when 'create' then @users[user.id] = { name : user.name , uid : user.id }
            when 'remove' then delete @users[user.id]
        do @display

    updateColumns : () =>
        nbUsers  = 0
        for uid of @users
            ++nbUsers
        height   = do (do @jqContainer.parent).height
        inOneCol = parseInt (height / 115)
        if inOneCol > nbUsers
            inOneCol = nbUsers
        columns  = parseInt (nbUsers / inOneCol + 0.5)
        @jqContainer.css 'width', columns * 118

    # Update the user list window.
    display         : () =>
        do @jqContainer.empty
        for uid of @users
            if @users[uid]?
                li = ($ '<li>', {
                    id    : "video_#{uid}"
                    class : 'thumbnail-wrapper video-wrapper color-three'
                })
                if @users[uid].video?
                    li.append @users[uid].video
                    do @users[uid].video.play
                @jqContainer.append li
        do @updateColumns

if window?
    window.UserList     = UserList
