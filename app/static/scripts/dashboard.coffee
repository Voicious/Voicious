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

bindView = (elemToclick, divToDisplay) ->
    ($ elemToclick).click () =>
        window.location.hash = ($ elemToclick).attr 'id'
        clickable = ($ elemToclick)
        clickable.addClass 'active'
        (clickable.siblings '.options').removeClass 'active'
        do (($ divToDisplay).siblings '.content.display').hide
        ($ divToDisplay).fadeIn '100'
        ($ divToDisplay).addClass 'display'
        (($ divToDisplay).siblings '.content.display').removeClass 'display'

onHoverEntry = () ->
    jqBoxHidder = ($ this).find '.boxHidder'
    jqJoinBox = ($ this).find '.joinBox'
    do jqBoxHidder.hide
    do jqJoinBox.show

onHoverOut = () ->
    jqBoxHidder = ($ this).find '.boxHidder'
    jqJoinBox = ($ this).find '.joinBox'
    do jqJoinBox.hide
    do jqBoxHidder.show

onFriendBoxHover = (friendBox) ->
    jqBox = ($ friendBox)
    jqBox.hover onHoverEntry, onHoverOut

onHoverFriendRow = () ->
    rows = ($ this).find '.friendRowElem.onHover'
    ($ rows).removeClass 'none'
    ($ '.friendRowElem.remove').hover onHoverRemove

outHoverFriendRow = () ->
    rows = ($ this).find '.friendRowElem.onHover'
    ($ rows).addClass 'none'
    ($ '.friendRowElem.removeFull').addClass 'none'

onHoverRemove = () ->
    ($ this).addClass 'none'
    ($ this).next().removeClass 'none'

# Initialize the dashboard by binding options to content and hide all the content.
configureForm = ()  ->
    ($ "#addFriend").submit (event) ->
        do event.preventDefault
        $.ajax '/friend',
            type: 'POST'
            dataType: 'json'
            data: {name: ($ ($ this).find('input[name=name]')[0]).val()}
            error: (jqXHR, textStatus, errorThrown) ->
                window.location.href = "/dashboard" + window.location.hash
                do window.location.reload
            success: (data, textStatus, jqXHR) ->
                window.location.href = "/dashboard" + window.location.hash
                do window.location.reload

init = () ->
    do configureForm
    options = ($ 'li.options')
    hash = undefined
    do $('.content').hide

    bindView (do options.first), '#roomsContent'
    bindView (options[1]),  '#friendsContent'
    bindView (options[2]),  '#settingsContent'

    if window.location.hash? and window.location.hash != ""
        hash = ($ "li" + window.location.hash + ".options")

    if (hash? and hash.length > 0)
        do hash.click
    else
        do (do options.first).click

    do ($ '.joinBox').hide

    ($ '.friendRoom').each () ->
        onFriendBoxHover($ this)

    ($ '.friendRow').hover onHoverFriendRow, outHoverFriendRow

    ($ '.joinRow').each () ->
        ($ this).click () ->
            roomID = ($ this).attr "data-rid"
            window.location.href = "/room/" + roomID

($ document).ready () =>
    do init
