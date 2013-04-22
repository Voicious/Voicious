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

class UserList extends Module
    # The user list contain all the informations of the guests in the room.
    constructor     : (emitter) ->
        super emitter
        @users  = []
        @jqElem = ($ '#userList > ul')
        li      = @jqElem.find 'div.accordion-heading'
        @users.push (do li.text)
        do @configureEvents

    configureEvents     : () =>
        @emitter.on 'peer.list', @fill
        @emitter.on 'peer.create', (event, user) =>
            @update 'create', user
        @emitter.on 'peer.remove', (event, user) =>
            @update 'remove', user

    # Fill the user list with new users.
    fill            : (event, data) =>
        for user in data.peers
            @users.push user.name
        do @display

    # Update the user list by creating or removing a user from the list.
    update          : (event, user) =>
        switch event
            when 'create' then @users.push user.name
            when 'remove' then @users.splice (@users.indexOf user.name), 1
        do @display

    # Update the user list window.
    display         : () =>
        do @jqElem.empty
        for user in @users
            jqNewLi      = ($ '<li>', { class : 'accordion-group' })
            jqNewHead    = ($ '<div>', { class : 'accordion-heading collapsed', 'data-toggle' : 'collapse', 'data-target' : "##{user}-userList", 'data-parent' : 'div#userList > ul' }).text user
            jqNewToggle  = ($ '<div>', { class : 'accordion-toggle collapse', id : "#{user}-userList" })
            jqNewPromote = ($ '<li>', { class : 'fontwhite disabled' }).text 'promote'
            jqNewKick    = ($ '<li>', { class : 'fontwhite disabled' }).text 'kick'
            jqNewAdd     = ($ '<li>', { class : 'fontwhite disabled' }).text 'add as a contact'
            jqNewToggle.append (((($ '<ul>').append jqNewPromote).append jqNewKick).append jqNewAdd)
            (jqNewLi.append jqNewHead).append jqNewToggle
            @jqElem.append jqNewLi
            jqNewToggle.on 'hide', () ->
                ((do ($ @).parent).children 'div.accordion-heading').addClass 'collapsed'

if window?
    window.UserList     = UserList
