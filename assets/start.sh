#!/bin/sh

cd "$(dirname "$(realpath "$0")")"

if [ -f /tmp/minecraft.pid ] && kill -0 $(cat /tmp/minecraft.pid) 2>/dev/null; then
    echo "The minecraft server is already running."
    exit 1
fi

echo $$ > /tmp/minecraft.pid

if [ ! -p /tmp/minecraft.fifo ]; then
    mkfifo /tmp/minecraft.fifo
fi

screen -D -m -S minecraft sh -c 'java -Xmx768M -Xms768M -jar ./*.jar nogui 2>&1 | tee /tmp/minecraft.fifo' &

exec cat /tmp/minecraft.fifo
