#!/bin/sh

cd "$(dirname "$(realpath "$0")")"

if [ ! -f /tmp/minecraft.pid ] || ! kill -0 $(cat /tmp/minecraft.pid) 2>/dev/null; then
    echo "The minecraft server is not running."
    exit 1
fi

screen -p 0 -S minecraft -X stuff "stop\015"

exec tail --pid=$(cat /tmp/minecraft.pid) -f /dev/null
