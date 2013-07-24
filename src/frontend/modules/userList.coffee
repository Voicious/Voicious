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
        do @configureEvents
        do @display
        ($ window).on 'resize', () =>
            do @updateColumns
        kick = 
            name : 'kick'
            callback : @kick
        @emitter.trigger 'cmd.register', kick

    initialize          : () =>
        @users[window.Voicious.currentUser._id] = window.Voicious.currentUser
        @users[window.Voicious.currentUser._id]['isLocal'] = on
        @users[window.Voicious.currentUser._id]['volume'] = on
        do @display

    configureEvents     : () =>
        @emitter.on 'peer.list', @fill
        @emitter.on 'peer.create', (event, user) =>
            @update 'create', user
        @emitter.on 'peer.remove', (event, user) =>
            @update 'remove', user
        @emitter.on 'stream.display', (event, video) =>
            uid = ($ video).attr 'rel'
            @users[uid].video = video
            video.volume = @users[uid]['volume']
            ($ "li#video_#{uid}").append video
        @emitter.on 'stream.create', (event, data) =>
            @toggleButtons data.uid, ['zoomBtn', 'muteBtn']
        @emitter.on 'stream.remove', (event, data) =>
            @toggleButtons data.id, ['zoomBtn', 'muteBtn']
        @emitter.on 'stream.zoom', (event, id) =>
            @zoomButton id

    # Fill the user list with new users.
    fill            : (event, data) =>
        for user in data.peers
            @users[user.id] = { name : user.name , uid : user.id, 'isLocal' : off, volume : on}
        do @display

    # Update the user list by creating or removing a user from the list.
    update          : (event, user) =>
        switch event
            when 'create'
                @users[user.id] = { name : user.name , uid : user.id, isLocal : off, volume : on }
                @createThumbnail user.id
            when 'remove'
                delete @users[user.id]
                do ($ "li#video_#{user.id}").remove

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

    muteStream   : (event) =>
        button = $ event.target
        mainLi = button.parents 'li.thumbnail-wrapper'
        video = (mainLi.find 'video')[0] # get the video tag for the li.
        if video?
            classI = if (do button.text) is 'mute' then 'icon-microphone' else 'icon-microphone-off'
            text = if (do button.text) is 'mute' then 'unmute' else 'mute'
            do button.empty
            button.append "<i class='#{classI}'></i>#{text}"
            @users[video.getAttribute 'rel']['volume'] = !@users[video.getAttribute 'rel']['volume']
            video.volume = @users[video.getAttribute 'rel']['volume']

    kickUser     : (event) =>
        mainLi = ($ event.target).parents 'li.thumbnail-wrapper'
        uid = (mainLi.attr 'id').slice '6' # Skip the `video_`
        msg =
          type   : 'cmd.kick'
          to     : uid
          params :
            message : ""
        @emitter.trigger 'message.sendToOneId', msg

    addInterface : (jqLi, login) =>
        intrfc = ($ "<i class='icon-eye-close nocam'></i>
                     <div class='frame user-square-controls'>
                         <div class='username'>#{login}</div>
                        <ul>
                            <li class='muteBtn'><i class='icon-microphone-off'></i>mute</li>
                            <li class='kickBtn'><i class='icon-ban-circle'></i>kick</li>
                            <li class='zoomBtn'><i class='icon-zoom-in'></i>zoom</li>" +
                            #<li><i class='icon-level-up'></i>promote</li>
                      "</ul>
                     </div>
                     <div class='cam-username-wrapper index1'><div class='cam-username'>#{login}</div></div>"
        ).appendTo jqLi
        (jqLi.find '.muteBtn').click @muteStream
        (jqLi.find '.kickBtn').click @kickUser

    # Display or hide buttons on thumbnail
    toggleButtons     : (id, buttonNames) =>
        ($ "li#video_#{id}").each (i, item) ->
            ($ item).find('li').each (i, item) ->
                button = ($ item)
                for name in buttonNames
                    if button.hasClass name
                        if button.css('display') is 'none' then do button.show else do button.hide

    # Change zoom button state
    zoomButton        : (id) =>
        ($ "li#video_#{id}").each (i, item) ->
            ($ item).find('li').each (i, item) ->
                button = ($ item)
                if button.hasClass 'zoomBtn'
                    className = if (do button.text) is 'zoom' then 'icon-zoom-in' else 'icon-zoom-out'
                    text = if (do button.text) is 'zoom' then 'unzoom' else 'zoom'
                    do button.empty
                    button.append "<i class='#{className}'></i>#{text}"

    # Update the user list window.
    display           : () =>
        do @jqContainer.empty
        for uid of @users
            @createThumbnail uid

    # Append new thumbnail on feeds
    createThumbnail   : (uid) =>
        li = ($ '<li>', {
            id    : "video_#{uid}"
            class : 'thumbnail-wrapper video-wrapper user-square color-one'
        })
        @addInterface li, @users[uid].name
        if @users[uid].video?
            li.append @users[uid].video
            do @users[uid].video.play
        if @users[uid].isLocal? and @users[uid].isLocal
            @jqContainer.prepend li
        else
            @jqContainer.append li
        if !@users[uid].video? then @toggleButtons uid, ['zoomBtn', 'muteBtn']
        do @updateColumns

    kick                : (params) =>
        console.log params
        if params[1]?
            reason = ''
            if params[2]?
                reason = (params.splice 2).join ' '
            message = { type : 'cmd.kick', to : params[1], params : { message : reason } }
            @emitter.trigger 'message.sendToOneName', message
        else
            @emitter.trigger 'chat.error', { text: params[0] + ": usage: /kick user [reason]"}
        
if window?
    window.UserList     = UserList
