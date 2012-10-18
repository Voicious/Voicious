class Client
        constructor: () ->
                console.log "instanciating new client"

        @default: () ->
                console.log "default function of client"

        @register: (name, gender) ->
                console.log "Name #{name}, gender #{gender}"

exports.Client = Client