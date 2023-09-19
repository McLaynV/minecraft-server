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

* Download your mods into `/opt/minecraft/server/mods/` and configure them in `/opt/minecraft/server/config/`
* Restart the service with the new mods: `systemctl restart MineCraft`

Debug
=====

* See the logs in `/opt/minecraft/server/logs/`
