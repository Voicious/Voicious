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

FadeIn = () =>
    ($ '#logo').fadeIn 1600
    (($ '#desc').delay 100).fadeIn 800
    ((($ '#choices').delay 100).fadeTo 0.01).animate {
        opacity     : 1,
        marginTop   : '+=20'
    }, 600

HideAllStates = () =>
    (($ document).find 'span.stateGroup > span.stateIcon').removeClass 'icon-ok icon-notok'
    (($ document).find 'span.stateGroup > span.errorMessage').removeClass 'inline'
    (($ document).find 'span.stateGroup > span.errorMessage').addClass 'none'

class JumpInStep
    constructor : (@father, @name) ->
        @_jqBtn     = PrivateValue.GetOnly ($ '#' + @name + 'Btn')
        @_jqDiv     = PrivateValue.GetOnly ($ 'div#' + @name)
        @_jqCancel  = PrivateValue.GetOnly ((do @_jqDiv.get).find '#' + @name + 'Cancel')
        @_jqElem    = PrivateValue.GetOnly (do @_jqDiv.get).find 'button'
        (do @_jqBtn.get).click @display
        (do @_jqCancel.get).click @hide

    # Displays the next step.
    display : (event) =>
        (do @_jqCancel.get).attr 'disabled', off
        (do @_jqBtn.get).attr 'disabled', on
        for elem in do (do @_jqDiv.get).siblings
            elemName = $(elem).attr 'id'
            if elemName isnt @name and elemName isnt (do @father._jqFirstStep.get).attr 'id'
                do $(elem).hide
        do @father.hide
        (do @_jqDiv.get).fadeTo 0.01
        (do @_jqDiv.get).animate {
            opacity : 1
            left    : '-=290'
        }, 600

    # Hides the previous step.
    hide : (event) =>
        (do @_jqBtn.get).attr 'disabled', off
        (do @_jqCancel.get).attr 'disabled', on
        do HideAllStates
        do @father.show
        (do @_jqDiv.get).fadeTo 0.99
        (do @_jqDiv.get).animate {
            opacity : 0
            left    : '+=290'
        }, 600

    # On form submit, fires the Javascript event 'blur'.
    fireAllBlurOnSubmit : () =>
        form    = (do @_jqDiv.get).children 'form'
        btn     = (do @_jqDiv.get).children 'button[type=submit]'
        btn.click (event) =>
            (form.find 'input').each () ->
                ($ @).trigger 'blur'

class ChoiceForm
    constructor : (@name) ->
        @_jqElem    = PrivateValue.GetOnly ($ '#' + @name)
        @_jqForm    = PrivateValue.GetOnly (do @_jqElem.get).find 'form'
        (do @_jqForm.get).submit @onSubmit
        for input in ((do @_jqForm.get).find 'input')
            ($ input).bind 'blur', @onFieldBlur
        do @fireAllBlurOnSubmit

    # On click, fires the Javascript event 'blur'.
    fireAllBlurOnSubmit : () =>
        ((do @_jqElem.get).find 'button[type=submit]').click (event) =>
            ((do @_jqElem.get).find 'input').each () ->
                ($ @).trigger 'blur'

    # Displays the form.
    display : () =>
        ($ document).trigger 'hideAllForms'
        ($ 'div#choicesContainer div.displayed').hide 0, () ->
            do HideAllStates
            ($ this).removeClass 'displayed'
            (($ this).find 'form').each () ->
                (($ this).find 'input').each () ->
                    ($ this).val ''
                    ($ this).removeClass 'error'
        (do @_jqElem.get).addClass 'displayed'
        window.location.hash    = @name
        (do @_jqElem.get).fadeIn 600

    # Displays the good field icon.
    displayFieldIcon : (field, ok) =>
        jqIcon      = ($ 'body').find "span.stateIcon[rel=#{field}]"
        jqMessage   = ($ 'body').find "span.errorMessage[rel=#{field}]"
        jqIcon.removeClass 'icon-ok icon-notok'
        jqMessage.removeClass 'inline none'
        if not ok
            jqIcon.addClass 'icon-notok'
            jqMessage.addClass 'inline'
        else
            jqIcon.addClass 'icon-ok'
            jqMessage.addClass 'none'
        
    # Checks value validity of a field.
    checkFieldValuePresence : (field, displayError) =>
        valid   = ((do @_jqForm.get).find "input##{field}")[0].validity.valid
        if not valid
            if displayError
                @displayFieldIcon field, no
            return false
        if displayError
            @displayFieldIcon field, yes
        return true

    onSubmit : (event) =>

    onFieldBlur : (event) =>
        @checkFieldValuePresence (($ event.target).attr 'id'), yes

class JumpInForm extends ChoiceForm
    constructor : (@name) ->
        @steps  = [
            new JumpInStep this, 'newRoom'
            new JumpInStep this, 'joinRoom'
        ]
        super @name
        @_jqFirstStep   = PrivateValue.GetOnly (do @_jqElem.get).find '#stepOne'
        @_jqBtn         = PrivateValue.GetOnly (do @_jqFirstStep.get).find 'button'

    # On form submit, fires the Javascript 'blur' event.
    fireAllBlurOnSubmit : () =>
        for step in @steps
            do step.fireAllBlurOnSubmit

    # Hides Jumpin form animation.
    hide : () =>
        (do @_jqFirstStep.get).fadeTo 0.99
        (do @_jqFirstStep.get).animate {
            opacity : 0
            left    : '-=290'
        }, 600
        
    # Shows Jumpin form animation.
    show : () =>
        (do @_jqFirstStep.get).fadeTo 0.01
        (do @_jqFirstStep.get).animate {
            opacity : 1
            left    : '+=290'
        }, 600

class SignUpForm extends ChoiceForm
    onSubmit : (event) =>
        if not (do @checkPasswordConfirmation)
            do event.preventDefault

    # Checks if the password matches with the confirm passowrd.
    checkPasswordConfirmation : () =>
        passwd  = do ((do @_jqForm.get).find 'input#signup_password').val
        confirm = do ((do @_jqForm.get).find 'input#signup_password_confirm').val
        if not passwd or not confirm or confirm isnt passwd
            return false
        return yes

    # Displays field icon matching with the field.
    displayFieldIcon : (field, ok) =>
        super field, ok
        if field is "signup_password"
            super "signup_password_confirm", ok

    # Checks password confirmation and displays the good field icon.
    onFieldBlur : (event) =>
        field   = ($ event.target).attr 'id'
        super event
        if field isnt 'signup_email'
            ok = if (do @checkPasswordConfirmation) then yes else no
            @displayFieldIcon 'signup_password', ok

class Choice
    constructor : (@name, formType = ChoiceForm) ->
        @_jqElem    = PrivateValue.GetOnly ($ '#' + @name + 'Btn')
        (do @_jqElem.get).click @onClick

        @_form      = PrivateValue.GetOnly (new formType @name)

    # On click, set the class to 'selected' and displays the form.
    onClick : (event) =>
        ($ 'div#choices li.selected').removeClass 'selected'
        (do @_jqElem.get).addClass 'selected'
        do (do @_form.get).display

($ document).ready () =>
    do ($ 'div').hide
    do ($ 'div#choicesContainer').show
    do ($ 'div#choicesContainer > div div').show
    do FadeIn
    choices =
        '#jumpIn'   : new Choice 'jumpIn', JumpInForm
        '#logIn'    : new Choice 'logIn'
        '#signUp'   : new Choice 'signUp', SignUpForm

    ($ document).on 'hideAllForms', (event) =>
        for c of choices
            do (do (do choices[c]._form.get)._jqElem.get).hide

    if window.location.hash? and choices[window.location.hash]?
        do choices[window.location.hash].onClick
        if window.erroron?
            if window.erroron.length > 0
                for error in erroron
                    (do choices[window.location.hash]._form.get).displayFieldIcon error
