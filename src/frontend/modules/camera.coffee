###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class Camera extends Module
    constructor : (connections) ->
        super connections
        @feedCount        = 0
        @jqFeedCount      = ($ 'span#nbFeed')
        @jqVideoContainer = ($ 'ul#videos')
        ($ 'button#joinConference').bind 'click', @enableCamera
        connections.defineAction 'stream.create', @newStream
        connections.defineAction 'peer.remove', @delStream

    delStream : (event, user) =>
        do ($ "li#video_#{user.id}").remove
        @refreshFeedCount -1

    newStream : (event, data) =>
        ($ data.video).addClass 'thumbnailVideo flipH'
        li = ($ '<li>', {
            id    : "video_#{data.uid}",
            class : 'thumbnail'
        }).appendTo @jqVideoContainer
        li.append data.video
        @refreshFeedCount 1

    enableCamera : () =>
        @connections.enableCamera (video) =>
            ($ 'div#notActivate').css 'display', 'none'
            video = ($ video)
            video.attr 'id', 'localVideo'
            video.addClass 'localVideo flipH'
            ($ 'div#localVideoContainer').append video

    refreshFeedCount : (modificator = 0) =>
        @feedCount += modificator
        @jqFeedCount.text @feedCount

if window?
    window.Camera = Camera
