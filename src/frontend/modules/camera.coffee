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
    constructor : (emitter) ->
        super emitter
        @feedCount        = 0
        @jqFeedCount      = ($ 'span#nbFeed')
        @jqVideoContainer = ($ 'ul#videos')
        @currentZoom      = undefined
        @streams          = [ ]
        ($ 'button#joinConference').bind 'click', @enableCamera
        @emitter.on 'stream.create', @newStream
        @emitter.on 'peer.remove', @delStream
        @emitter.on 'camera.localstream', (event, video) =>
            ($ 'div#notActivate').css 'display', 'none'
            video = ($ video)
            video.attr 'id', 'localVideo'
            video.addClass 'localVideo flipH thumbnailVideo'
            ($ '#localVideoContainer').append video
            do video[0].play
            video.bind 'click', () =>
                @zoom '', video

    delStream : (event, user) =>
        if (@streams.indexOf user.id) >= 0
            do ($ "li#video_#{user.id}").remove
            @refreshFeedCount -1
            @streams.splice user.id, 1
            if @currentZoom is user.id
                @zoom undefined, undefined

    newStream : (event, data) =>
        @streams.push data.uid
        video = ($ data.video)
        video.addClass 'thumbnailVideo flipH'
        li = ($ '<li>', {
            id    : "video_#{data.uid}",
            class : 'thumbnail-wrapper'
        }).appendTo @jqVideoContainer
        li.append video
        @refreshFeedCount 1
        do video[0].play
        video.bind 'click', () =>
            @zoom data.uid, video

    enableCamera : () =>
        @emitter.trigger 'camera.enable'

    zoom : (uid, video) =>
        container    = ($ 'div#mainCam')
        container.removeClass 'hidden'
        do (container.find 'video').remove
        @currentZoom = uid
        if video?
            newVideo     = do video.clone
            newVideo.removeClass 'thumbnailVideo'
            do newVideo[0].play
            container.append newVideo

    refreshFeedCount : (modificator = 0) =>
        @feedCount += modificator
        @jqFeedCount.text @feedCount

if window?
    window.Camera = Camera
