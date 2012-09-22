#!/bin/bash

#
#require package inotify-tools for inotifywait binary
#

compile_coffee()
{
    echo $1
    if [ $1 ]; then
        coffee_path="$(which 'coffee')"
        echo 32768 > /proc/sys/fs/inotify/max_user_watches
        inotifywait --excludei '.*\.(html|txt|save|css|js|png|jpg|xml)' -e modify -r -m $1 \
            | while read folder modification file
        do
            if echo $file | grep -q '\.coffee$'
            then
                path="$folder$file"
                $coffee_path -c "$path"
            fi
        done
    else
        logger -s "Missing directory name"
        exit 1
    fi
}

usage()
{
    logger -s "Usage $0 start directory_name"
    exit 1
}

compile_start()
{
    if ! ps aux | grep "$0 [c]offee" > /dev/null ; then
        $0 coffee $2 &
    else
        logger -s "Already running !"
    fi
}

autocompile()
{
    case "$1" in
        start) compile_start $*;;
        coffee) compile_coffee $2 ;;
        *) usage ;;
    esac
}

autocompile $*
