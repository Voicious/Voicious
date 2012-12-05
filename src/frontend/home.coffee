###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

FadeIn  = () =>
    ($ '#logo').fadeIn 1600
    (($ '#desc').delay 100).fadeIn 800
    ((($ '#choices').delay 100).fadeTo 0.01).animate {
        opacity     : 1,
        marginTop   : '+=20'
    }, 600

class ChoiceForm
    constructor : (@name) ->
        @_jqElem    = PrivateValue.GetOnly ($ '#' + @name)
        @_jqForm    = PrivateValue.GetOnly (do @_jqElem.get).find 'form'
        (do @_jqForm.get).submit @onSubmit

    display     : () =>
        do ($ '#msg').empty
        ($ 'span#choicesContainer div.displayed').hide 0, () ->
            ($ this).removeClass 'displayed'
            (($ this).find 'form').each () ->
                (($ this).find 'input').each () ->
                    ($ this).val ""
        (do @_jqElem.get).addClass 'displayed'
        window.location.hash    = @name
        (do @_jqElem.get).fadeIn 600

    onSubmit    : (event) =>

class SignUpForm extends ChoiceForm
    onSubmit    : (event) =>
        mail    = do ((do @_jqForm.get).find 'input#signup_email').val
        passwd  = do ((do @_jqForm.get).find 'input#signup_password').val
        confirm = do ((do @_jqForm.get).find 'input#signup_password_confirm').val
        err     = (if not mail then "Missing field : Email<br />" else "")
        if not passwd
            err += "Missing field : Password<br />"
        else if not confirm
            err += "Missing field : Password<br />"
        else if confirm isnt passwd
            err += "Password and confirmation do not match !<br />"
        if err
            do event.preventDefault
            ($ '#msg').html err

class Choice
    constructor  : (@name, formType = ChoiceForm) ->
        @_jqElem    = PrivateValue.GetOnly ($ '#' + @name + 'Btn')
        (do @_jqElem.get).click @onClick

        @_form      = PrivateValue.GetOnly (new formType @name)

    onClick     : (event) =>
        ($ 'div#choices li.selected').removeClass 'selected'
        (do @_jqElem.get).addClass 'selected'
        do (do @_form.get).display

($ document).ready () =>
    do ($ 'div').hide
    do ($ 'span#choicesContainer > div div').show
    do FadeIn
    choices =
        '#jumpIn'   : new Choice 'jumpIn'
        '#logIn'    : new Choice 'logIn'
        '#signUp'   : new Choice 'signUp', SignUpForm
    
    if window.location.hash? and choices[window.location.hash]?
        do choices[window.location.hash].onClick
