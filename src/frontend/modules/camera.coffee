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
        ($ 'button#joinConference').bind 'click', @enableCamera

    enableCamera : () =>
        @connections.enableCamera (video) =>
            ($ 'div#notActivate').css 'display', 'none'
            video = ($ video)
            video.attr 'id', 'localVideo'
            video.addClass 'localVideo'
            ($ 'div#localVideoContainer').append video

if window?
    window.Camera = Camera
