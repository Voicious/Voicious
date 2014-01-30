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
        do @appendHTML
        @jqMainCams       = ($ '#mainCam')
        @jqVideoContainer = ($ 'ul#videos')
        @zoomCams         = { }
        @streams          = [ ]
        @mosaicNb         = 1
        @diaporama        = off
        @diapoIndex       = 0
        @emitter.on 'stream.create', @newStream
        @emitter.on 'stream.remove', (event, user) =>
            for key, value of @zoomCams
                if key is user.uid
                    @zoom user.uid, undefined
            do ($ "[data-streamid=#{user.id}]").remove
        @emitter.on 'peer.remove', @delStream
        @emitter.on 'camera.localstream', (event, data) =>
            data.video.muted = yes
            @newStream event, { video : data.video, type: data.type, uid : window.Voicious.currentUser._id , local : yes }
        do @diaporamaMode
        ($ window).on 'resize', () =>
            videos = ($ 'video')
            for video in videos
                @centerVideoTag ($ video)
            do @resizeZoomCams
        ($ document).on 'DOMNodeInserted', 'video', (event) =>
            @centerVideoTag ($ event.currentTarget)
        ($ '#feeds').delegate '.zoomBtn', 'click', (event) =>
            clickButton = ($ event.target)
            mainLi = clickButton.parents 'li.thumbnail-wrapper'
            video = (mainLi.find 'video')
            if video?
                @zoom (video.attr 'rel'), video

    delStream   : (event, user) =>
        if (@streams.indexOf user.id) >= 0
            do ($ "li#video_#{user.id}").remove
            @streams.splice user.id, 1
            for key, value of @zoomCams
                if key is user.id
                    @zoom user.id, undefined
                    return

    newStream : (event, data) =>
        @streams.push data.uid
        video = ($ data.video)
        if data.local? and data.local is true
            video.addClass 'flipH'
        video.addClass 'thumbnailVideo'
        video.attr 'rel', data.uid
        @emitter.trigger 'stream.display', video
        if !data.local? and data.type is 'video'
            @zoom data.uid, video

    # Must set margin-left css propriety when adding a video tag to the page
    # Width is computed using video original size (640 * 480) since css value is wrong at this time
    centerVideoTag : (video) =>
        marginleft = ((do video.height) * 640 / 480) / 2
        video.css 'margin-left', -marginleft
        do video[0].play

    resizeZoomCams : () =>
        cam = ($ '#mainCam')
        cameras = cam.find 'li.zoom-cam'
        x = do cam.width
        y = do cam.height
        n = cameras.length
        px = Math.ceil(Math.sqrt(n * x / y))
        if n is 0
            return
        if Math.floor(px * y / x) * px < n
            sx = y / Math.ceil(px * y / x)
        else
            sx = x / px

        py = Math.ceil(Math.sqrt(n * y/ x))
        if Math.floor(py * x / y) * py < n
            sy = x / Math.ceil(x * py / y)
        else
            sy = y / py
        size = if sx > sy then sx else sy
        size = size - 10 # trash fix
        cameras.each (index) =>
            ($ cameras[index]).css 'width', "#{size}px"
            ($ cameras[index]).css 'height', "#{size}px"
            @centerVideoTag (($ cameras[index]).find 'video')

    zoom : (uid, video) =>
        detached = @detachToMainCam uid, video
        if video? and detached is false
            @attachToMainCam uid, video

    attachToMainCam : (uid, video) =>
        container = ($ '#mainCam')
        newVideo     = do video.clone
        newVideo[0].volume = video[0].volume
        newVideo.removeClass 'thumbnailVideo'
        do newVideo[0].play
        html = ($ "<li id='zoomcam_#{uid}' class='zoom-cam-wrapper zoom-cam'>
                        <div class='zoom-control index1'>
                            <ul>
                                <li class='closeBtn'><i class='icon-remove'></i></li>
                            </ul>
                        </div>
                    </li>")
        (html.find '.closeBtn').click () =>
            @zoom uid, undefined
        html.append newVideo
        container.append html
        @centerVideoTag newVideo
        @zoomCams[uid] = ($ "li#zoomcam_#{uid}")
        do @resizeZoomCams

    detachToMainCam : (uid, video) =>
        detached = true
        container    = ($ '#mainCam')
        container.removeClass 'hidden'
        @emitter.trigger 'stream.zoom', uid
        for key, value of @zoomCams
            if key is uid
                do value.remove
                delete @zoomCams[uid]
                do @resizeZoomCams
                return detached
        detached = false
        return detached

    diaporamaMode     : () =>
        # shortcut.add 'Ctrl+Shift+M', () =>
        #     if @diaporama is off
        #         @diaporama = on
        #         for key, value of @zoomCams
        #             do value.remove
        #             delete @zoomCams[key]
        #         do @autoChangeMainCam
        #         @diapoTimer = setInterval @autoChangeMainCam, 3000
        #     else
        #         @diaporama = off
        #         clearInterval @diapoTimer

    autoChangeMainCam : () =>
        mainCam = ($ '#mainCam')
        clients = ($ '#feeds > li')
        if @diapoIndex isnt 0 and clients.length > 2
            for key, value of @zoomCams
                do value.remove
                oldKey = key
                delete @zoomCams[key]
        if clients.length >= 2
            clients.each (index) =>
                if index > 0
                    if index is clients.length - 1
                        video = ($ clients[1]).find('video')
                        uid = ($ video).attr('rel')
                        @diapoIndex = 1
                        @attachToMainCam uid, ($ video)
                        return
                    else if index > @diapoIndex
                        video = ($ clients[index]).find('video')
                        uid = ($ video).attr('rel')
                        @diapoIndex = index
                        @attachToMainCam uid, ($ video)
                        return

if window?
    window.Camera = Camera
