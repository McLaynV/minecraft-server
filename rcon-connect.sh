#!/usr/bin/env bash

. <(grep rcon </opt/minecraft/server/server.properties | sed 's/[^=_a-zA-Z0-9]/_/g')

cd /opt/minecraft/rcon
python3 demo.py localhost "${rcon_port}" "${rcon_password}"
