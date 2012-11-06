class Room
        constructor: ->
                console.log "Room construction"

        @default: ->
                console.log "Default function of Room"
                rootTab = {toto: "toto", tata: "tata"}
                return rootTab

exports.room = Room