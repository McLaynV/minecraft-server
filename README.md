About
=====

This is a simple way to setup a MineCraft Fabric server as a Linux service. 

It does automatic backups into your Git repository with a set frequency. 
A backup is also done each time the MineCraft service stops.

You can configure the versions by adding params to the `install.sh` script.
You can also configure the frequency of automatic backups.
See `install.sh --help` for details.


Instructions
============

GitHub
------

* Create a [new private GitHub repo](https://github.com/new) where your backups will be saved
* Add yourself as an Admin of the repo
* Create an access token
  * GitHub > Settings > Developer settings > Personal access tokens > [Genereate new token](https://github.com/settings/personal-access-tokens/new)
  * Token name: MineCraft
  * Expiration: as long as possible
  * Repository access: Only selected repositories: (name of the repo for your backups)
  * Permissions:
    * Contents: Read and write
  * Generate token
    * Copy the value - you will be using it instead of your password

Server
------

* Prepare a Linux server
  * Tested on Ubuntu 22.04 LTS.
  * DigitalOcean gives you $200 to be used during the first 60 days if you register with [this refferal link](https://m.do.co/c/dba1347dcfc8). 
    Check if the refferal offer still stands on the [DigitalOcean web](https://www.digitalocean.com/referral-program)
* Install git
  * `sudo apt install git -y`
  * `sudo dnf install git -y`

Installation
------------

* Run the following commands

```bash
sudo -i
mkdir -p /opt/minecraft/server/mods /opt/minecraft/server/config
cd /opt/minecraft/server
git_repo_owner=                  # specify repo owner username
git_repo_name=minecraft-server   # specify repo name
git_branch_name=main             # specify branch name to be checked out and used for backups
git_username="${git_repo_owner}" # specify your username for which you have generated the access token on GitHub

# create a private fork
git clone --bare "https://github.com/McLaynV/minecraft-server.git"
cd minecraft-server.git
git push --mirror "https://${git_username}@github.com/${git_repo_owner}/${git_repo_name}.git"
cd ..
rm -rf minecraft-server.git

# initialize git
git init .
git remote add -t '*' -f origin "https://${git_username}@github.com/${git_repo_owner}/${git_repo_name}.git" # use the access token instead of your password
git checkout "${git_branch_name}"
```

* Run the installation 
  * `sudo bash install.sh [--help]`
  * Without any params default values are used
  * Run with `--help` to see the configurable params
* Agree to the MineCraft EULA
  * `echo "eula=true" >eula.txt`
* Initialize credentials store
  * `sudo -u minecraft /opt/minecraft/server/backup.sh init`
  * Again use the access token instead of your password
* Mods
  * Fabric mods are supported.
    * Download your mods into `/opt/minecraft/server/mods/` 
    * Configure them in `/opt/minecraft/server/config/`
    * For example upload the directories in your home dir and call
      * `rsync -a /home/${SUDO_USER}/config/* /opt/minecraft/server/config/`
      * `rsync -a /home/${SUDO_USER}/mods/*   /opt/minecraft/server/mods/`
* Start the service
  * `systemctl start MineCraft`
  * `systemctl status MineCraft`

Configuration
=============

* Java memory size `-Xms` and `-Xmx` can be set in
  * `MineCraft.service` if you run it as a Linux service
  * `run.sh` if you run it manually on Linux
  * `run.cmd` if you run it manually on Windows
* `server.properties` 
  * See the [Wiki](https://minecraft.fandom.com/wiki/Server.properties)
  * Don't forget to change your `rcon` password if the rcon port will be open to the internet
  * You can find your perfect `level-seed` using [ChunkBase seed map](https://www.chunkbase.com/apps/seed-map) or leave it empty to get a random one
* `server-icon.png` - 64x64 PNG image
* Mods configuration in `/opt/minecraft/server/config/`

Debug
=====

* See the service status by `systemctl status MineCraft`
* See the logs in `/opt/minecraft/server/logs/`
  * `tail -f /opt/minecraft/server/logs/latest.log`
* See the logs in `journalctl --unit=MineCraft.service`
* Reset ownership of files if you did manual changes `chown -R minecraft:minecraft /opt/minecraft/server/`

Upgrade server version
======================

* Upgrade the versions in the `install.sh` script
* Run the `install.sh` script again
  * `TODO:` To be verified and debugged
* Upgrade mods in `/opt/minecraft/server/mods/`
