User = {
        default: (name, age) ->
                console.log "default function of user"

        register: (name, age) ->
                console.log "Name #{name}, age #{age}"
}

exports.User = User