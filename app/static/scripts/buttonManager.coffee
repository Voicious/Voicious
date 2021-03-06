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

class ButtonManager
    constructor : (@emitter) ->
        @_jqContainer = ($ '#sidebarAcc')
        @_jqContainer.accordion { active: false, collapsible: true, heightStyle: 'content', icons: off }
        @emitter.on 'button.create', @createButton

    createButton : (event, params) =>
        @_jqContainer.accordion 'destroy'
        newButton
        if params.outer?
            newButton = @createInnerButton params.outer, params.name, params.icon, params.rank
        else
            newButton = @createOuterButton params.name, params.icon, params.rank
        if params.click?
            if typeof params.click is 'function'
                newButton.click params.click
            else if params.click.popover?
                newButton.popover params.click.popover
        if params.attrs?
            for key, value of params.attrs
                newButton.attr key, value
        @_jqContainer.accordion { active: false, collapsible: true, heightStyle: 'content', icons: off }
        if params.callback?
            params.callback newButton

    createOuterButton : (name, icon, rank = -1) =>
        newButton = $ '<span>', { class : 'headerAcc white bordered shadowed' , id : 'btn_' + Utilities.slugify name }
        newButton.text name
        ($ '<i>', { class : "icon-#{icon}" }).prependTo newButton
        buttons   = @_jqContainer.children 'span.headerAcc'
        if rank is -1 or rank >= buttons.length
            newButton.appendTo @_jqContainer
        else
            ($ buttons[rank]).before newButton
        newButton.after ($ '<ul>', { class : 'white' })

    createInnerButton : (outer, name, icon, rank = -1) =>
        newButton = $ '<li>', { id : 'btn_' + Utilities.slugify name }
        newButton.text name
        ($ '<i>', { class : "icon-#{icon}" }).prependTo newButton
        container = (@_jqContainer.children '#btn_' + Utilities.slugify outer).next 'ul'
        buttons   = container.children 'li'
        if rank is -1 or rank >= buttons.length
            newButton.appendTo container
        else
            ($ buttons[rank]).before newButton
        newButton

if window.Voicious?
    window.Voicious.ButtonManager = ButtonManager
