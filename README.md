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

Tested on Ubuntu 22.04 LTS.

* Fork this repo
* Apply the changes to the parameters in `install.sh` as mentioned above
* Install git
  * `sudo apt install git -y`
  * `sudo dnf install git -y`
* Create an access token
  * GitHub > Settings > Developer settings > Personal access tokens > [Genereate new token](https://github.com/settings/personal-access-tokens/new)
  * Token name: MineCraft
  * Repository access: Only selected repositories: minecraft-server
  * Permissions:
    * Contents: Read and write
  * Generate token
    * Copy the value - you will be using it instead of your password
* Run the following commands

```bash
sudo -i
mkdir -p /opt/minecraft/server/mods /opt/minecraft/server/config
cd /opt/minecraft/server
git init .
git_username= # specify repo owner username
git remote add -t '*' -f origin "https://github.com/${git_username}/minecraft-server.git"
git checkout main
bash install.sh
```

* Agree to the MineCraft EULA
  * `echo "eula=true" >eula.txt`
* Initialize credentials store
  * `sudo -u minecraft /opt/minecraft/server/backup.sh init`
* Start the service
  * `systemctl start MineCraft`
  * `systemctl status MineCraft`

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
* `server.properties` 
  * See the [Wiki](https://minecraft.fandom.com/wiki/Server.properties)
  * Don't forget to change your `rcon` password if the rcon port will be open to the internet
* `server-icon.png` - 64x64 PNG image

Debug
=====

* See the service status by `systemctl status MineCraft`
* See the logs in `/opt/minecraft/server/logs/`
* See the logs in `journalctl --unit=MineCraft.service`
