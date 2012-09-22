$(document).ready ->
    $('div').hide()

$(window).load ->
        logo = $('#logo')
        soon = $('#soon')
        desc = $('#desc')

        logo.fadeIn(1600)
        soon.fadeIn(1600)
        desc.delay(100).fadeIn(800)