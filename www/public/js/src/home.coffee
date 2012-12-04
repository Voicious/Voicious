$(document).ready () ->
    $('div').hide()

class Home
    constructor: () ->
        @_stepOne = $('#stepOne')
        @_choices = $('#choices')
        initToggleTable = (selector) ->
            toggle: false
            domObj: ($ selector)
        @_lis = [
            initToggleTable '#quick'
            initToggleTable '#signin'
            initToggleTable '#signup'
            ]

    init: () ->
        $('#logo').fadeIn 1600
        ($('#desc').delay 100).fadeIn 800
        (@_choices.delay 100).fadeTo 0.01
        @_choices.animate {
            opacity: 1,
            marginTop: '+=20'
            }, 600
        @_stepOne.show()
        @bindEvent()
        $('#newRoomBtn').click () =>
            @nextStep stepOne, $('#newRoom')
        $('#newRoomCancel').click () =>
            @cancelStep stepOne, $('#newRoom')
        $('#joinRoomBtn').click () =>
            @nextStep stepOne, $('#joinRoom')
        $('#joinRoomCancel').click () =>
            @cancelStep stepOne, $('#joinRoom')
        @signup()


    bindEvent: () ->
        that = this
        for i in [0..@_lis.length - 1]
            $('#choices ul li.choice:nth-child(' + (i + 1) + ')').click () ->
                index = $(this).index()
                $('li.selected').removeClass 'selected'
                if that._lis[index]['toggle'] is off
                    for key, li of that._lis
                        if Number(key) is index
                            li['toggle'] = true
                            li.domObj.fadeIn 600
                        else
                            li['toggle'] = false
                            li.domObj.hide()
                else
                    that._lis[index]['toggle'] = false
                    that._lis[index]['domObj'].fadeOut 200
                $(this).toggleClass 'selected', that._lis[index]['toggle']

    disableButtonClick: (element) ->
        $('#' + element.get(0).id + ' button').attr 'disabled', on

    enableButtonClick: (element) ->
        $('#' + element.get(0).id + ' button').attr 'disabled', off

    nextStep: (stepOne, stepTwo) ->
        stepOne = $(stepOne)
        stepTwo = $(stepTwo)
        @disableButtonClick stepOne
        @enableButtonClick stepTwo
        $('#joinRoom,#newRoom').hide()
        stepOne.fadeTo 0.99
        stepOne.animate {
            opacity: 0
            left: '-=290'
            }, 600
        stepTwo.fadeTo 0.01
        stepTwo.animate {
            opacity: 1
            left: '-=290'
            }, 600

    cancelStep: (stepOne, stepTwo) ->
        stepOne = $(stepOne)
        stepTwo = $(stepTwo)
        @enableButtonClick stepOne
        @disableButtonClick stepTwo
        stepOne.fadeTo 0.01
        stepOne.animate {
            opacity: 1
            left: '+=290'
            }, 600
        stepTwo.fadeTo 0.99
        stepTwo.animate {
            opacity: 0
            left: '+=290'
            }, 600
        $('#' + stepTwo.get(0).id + ' form input').attr 'value', ''
        $('#' + stepTwo.get(0).id + ' form input').blur()

    signup: () ->
        $('#signup-btn').click () =>
                email = $('#signup_email').val()
                password = $('#signup_password').val()
                confirm = $('#signup_password_confirm').val()
                emailExp = new RegExp "^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$", "i"
                passwordExp = new RegExp "^(?=.*[a-z])(?!.*[^a-z0-9]).{5,}$", "gi"
                evalEmail = emailExp.test email
                evalPassword = passwordExp.test password
                msg = ""

                if email == "" || password == "" || confirm == ""
                        $('#msg').html "Incomplete form"
                        return
                if evalEmail != true
                        msg += "Invalid email<br/>"
                if evalPassword != true
                        msg += "Password must be at least 5 characters<br/>"
                if password != confirm
                        msg += "Password does not match the confirm password"
                $('#msg').html msg
                if evalEmail && evalPassword && password == confirm
                        $('#msg').html "Registration confirmed."
                        $.ajax {
                                type: "POST",
                                url: "/user",
                                data: { "mail": email, "password": password },
                                dataType: "json"
                        }

$(window).load ->
    home = new Home
    home.init()
