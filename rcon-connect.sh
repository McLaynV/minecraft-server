#!/usr/bin/env bash

. <(grep rcon </opt/minecraft/server/server.properties | sed 's/\./_/g')

cd /opt/minecraft/rcon
./demo.py --host=localhost --port="${rcon_port}" --password="${rcon_password}"
