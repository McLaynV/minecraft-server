About
=====

This is a simple way to setup a MineCraft Fabric server as a Linux service. 

You can configure the versions by setting `ver_mc`, `ver_loader` and `ver_launcher` in the `install.sh` script.
See the [Fabric server download page](https://fabricmc.net/use/server/) to select the version values.

It does automatic backups into your Git repository. 
You can configure the frequency of backups by setting `cron_minutes` in the `install.sh` script.
A backup is also done after the MineCraft service stops.

Instructions
============

* Fork this repo
* Run the following commands

```bash
mkdir -p /opt/minecraft/server/mods
mkdir -p /opt/minecraft/server/config
cd       /opt/minecraft/server
git clone "https://github.com/YOUR_USERNAME/minecraft-server.git" # specify YOUR_USERNAME
sudo install.sh
```

Mods
====

Fabric mods are supported.

* Download your mods into `/opt/minecraft/server/mods/` and configure them in `/opt/minecraft/server/config/`
* Restart the service with the new mods: `systemctl restart MineCraft`

Configuration
=============

* Java memory size `-Xms` and `-Xmx` can be set in
  * `MineCraft.service` if you run it as a Linux service
  * `run.sh` if you run it manually on Linux
  * `run.cmd` if you run it manually on Windows
* `server.properties` - see the [Wiki](https://minecraft.fandom.com/wiki/Server.properties)
* `server-icon.png` - 64x64 PNG image

Debug
=====

* See the logs in `/opt/minecraft/server/logs/`
