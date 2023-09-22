#!/usr/bin/python3

from mcipc.rcon.je import Client     # For Java Edition servers.
from jproperties import Properties

properties = Properties()
with open('/opt/minecraft/server/server.properties', 'rb') as server_properties_file:
    properties.load(server_properties_file)

rcon_port=int(properties.get('rcon.port').data)
rcon_pass=properties.get('rcon.password').data

with Client('127.0.0.1', rcon_port, passwd=rcon_pass) as rcon_client:
    players = rcon_client.list()
    print(players)
    stop=rcon_client.stop()
    print(stop)
