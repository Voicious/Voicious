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

quick = undefined
signIn = undefined
cancel = undefined
tabs = undefined
rememberMe = undefined
rememberMeBox = undefined
rememberMeIconTick = undefined
quickChoices = undefined
containers = undefined

displaySection = (element) =>
    element = ($ element)
    if not element.hasClass 'active'
        (do element.siblings).removeClass 'active'
        element.addClass 'active'
    container = ($ containers[element.attr 'id'])
    do (container.siblings '.stepContainer').hide
    container.fadeIn 100

displayStep = (element) =>
    element = ($ element)
    step    = ($ containers[element.attr 'id'])
    do (do step.siblings).hide
    step.fadeTo 0, 0.1
    (step.css 'right', '-50px').animate {
        opacity : 1
        right   : 0
    }, 200

init = () =>
    quick              = ($ '#quick')
    signin             = ($ '#signin')
    cancel             = ($ '.btn-cancel')
    tabs               = ($ '.tabs > div')
    rememberMe         = ($ '.rememberMe')
    rememberMeBox      = ($ '#rememberMe')
    rememberMeIconTick = ($ '.rememberMe i')
    quickChoices       = ($ '#quickInitial > button')
    containers         =
        quick          : '#quickContainer'
        signin         : '#signinContainer'
        quickCreateBtn : '#quickCreate'
        quickJoinBtn   : '#quickJoin'
    ($ 'button').attr 'tabindex', '-1'

    tabs.click () ->
        displaySection @

    quickChoices.click () ->
        displayStep @

    cancel.click () ->
        parent = ($ @).parents '.step'
        parent.animate {
            opacity : 0
            right   : '-50'
        }, 200, () =>
            do parent.hide
            ($ '#quickInitial').fadeIn 100

    rememberMe.click () ->
        ($ @).toggleClass 'checked'
        rememberMeBox.prop 'checked', not rememberMeBox.prop 'checked'
        rememberMeIconTick.attr 'class', (if rememberMeBox.prop 'checked' then 'icon-check' else 'icon-check-empty')

($ document).ready () =>
    do init
    displaySection quick
