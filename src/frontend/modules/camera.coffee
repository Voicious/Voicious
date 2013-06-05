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

class Camera extends Module
    constructor : (emitter) ->
        super emitter
        @jqMainCams       = ($ '#mainCam')
        @jqVideoContainer = ($ 'ul#videos')
        @currentZoom      = undefined
        @streams          = [ ]
        ($ 'button#joinConference').bind 'click', @enableCamera
        do @enableCamera
        @emitter.on 'stream.create', @newStream
        @emitter.on 'peer.remove', @delStream
        @emitter.on 'camera.localstream', (event, video) =>
            video.muted = yes
            @newStream event, { video : video , uid : window.Voicious.currentUser.uid }
        ($ window).on 'resize', () =>
            do @squareMainCam
            videos = ($ 'video')
            for video in videos
                @centerVideoTag { currentTarget : video }
        ($ document).on 'DOMNodeInserted', 'video', @centerVideoTag
        ($ '#feeds').delegate 'video', 'click', (event) =>
            clickedVideo = ($ event.target)
            @zoom (clickedVideo.attr 'rel'), clickedVideo
        do @squareMainCam

    squareMainCam : () =>
        @jqMainCams.width do @jqMainCams.height

    appendHTML  : () ->
        html = ($ '<div class="row-fluid" id="bottom-row">
            <div class="darkgray span12" id="camera">
                <ul id="videos">
                    <li class="box thumbnail-wrapper"></li>
                    <div class="localVideoContainer box"></div>
                </ul>
            </div>
        </div>')
        ($ '#middle-row').after html
        ($ '<div class="darkgray fill-height module" id="mainCam"></div>').appendTo '#middle-row'
        $(window).trigger 'resize'

    delStream   : (event, user) =>
        if (@streams.indexOf user.id) >= 0
            do ($ "li#video_#{user.id}").remove
            @streams.splice user.id, 1
            if @currentZoom is user.id
                @zoom undefined, undefined

    newStream : (event, data) =>
        @streams.push data.uid
        video = ($ data.video)
        video.addClass 'thumbnailVideo flipH'
        video.attr 'rel', data.uid
        @emitter.trigger 'stream.display', video

    # Must set margin-left css propriety when adding a video tag to the page
    # Width is computed using video original size (640 * 480) since css value is wrong at this time
    centerVideoTag : (event) =>
        jqTag      = ($ event.currentTarget)
        marginleft = ((do jqTag.height) * 640 / 480) / 2
        jqTag.css 'margin-left', -marginleft
        do event.currentTarget.play

    enableCamera : () =>
        @emitter.trigger 'camera.enable'

    zoom : (uid, video) =>
        container    = ($ 'div#mainCam')
        container.removeClass 'hidden'
        do (container.find 'video').remove
        @currentZoom = uid
        if video?
            newVideo     = do video.clone
            if video[0].muted
                newVideo[0].muted = 1
            newVideo.removeClass 'thumbnailVideo'
            do newVideo[0].play
            container.append newVideo

if window?
    window.Camera = Camera
