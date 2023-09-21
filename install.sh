#!/usr/bin/env bash

if [[ "$(whoami)" != root ]]; then
  sudo "${0}" "${@}"
  exit "${?}"
fi

chmod 750 *.sh

# find package manager
if apt --version 2>/dev/null; then
  pac_man=apt
elif dnf --version 2>/dev/null; then
  pac_man=dnf
else
  echo "No package manager found."
  exit 1
fi

# install packages
function install_package_if_not() {
  local package="${1}"
  shift
  local query=("${@}")
  "${query[@]}" 2>/dev/null || "${pac_man}" install "${package}" -y
}
install_package_if_not "git" git --version
#install_package_if_not "tmux" tmux -V
install_package_if_not "openjdk-17-jre" java -version
#install_package_if_not "python3" python3 --version
install_package_if_not "curl" curl --version

# create service user
useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft

mkdir -p /opt/minecraft/rcon
cd /opt/minecraft/rcon
git clone "https://github.com/barneygale/MCRcon.git"

# crontab for backups
cron_minutes=30
cat                    >/var/spool/cron/crontabs/minecraft <<<"*/${cron_minutes} * * * * /opt/minecraft/server/backup.sh crontab >> /opt/minecraft/server/logs/backup.log"
chown minecraft:crontab /var/spool/cron/crontabs/minecraft
chmod 600               /var/spool/cron/crontabs/minecraft

# firewall - allow service port
if firewall-cmd --version; then
  cat <<EOF >/etc/firewalld/services/MineCraft.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
 <short>MineCraft</short>
 <description>MineCraft server</description>
 <port protocol="tcp" port="25565"/>
</service>
EOF
  systemctl restart firewalld
  firewall-cmd --permanent --service=MineCraft
  systemctl restart firewalld
elif ufw --version; then
  ufw allow 25565/tcp comment 'accept MineCraft'
else
  echo "Firewall not supported."
  exit 1
fi

(
  cd /opt/minecraft/server

  # download minecraft server fabric loader
  # https://fabricmc.net/use/server/
  ver_mc=1.20.1
  ver_loader=0.14.22
  ver_launcher=0.11.2
  curl -OJ "https://meta.fabricmc.net/v2/versions/loader/${ver_mc}/${ver_loader}/${ver_launcher}/server/jar"
  rm -f server.jar
  ln -s "fabric-server-mc.${ver_mc}-loader.${ver_loader}-launcher.${ver_launcher}.jar" server.jar
)

chown -R minecraft:minecraft /opt/minecraft
chmod 644 /opt/minecraft/server/*.jar

# TODO: configure git credentials

# install service
ln -f -s /opt/minecraft/server/MineCraft.service /etc/systemd/system/MineCraft.service
systemctl daemon-reload
systemctl start  MineCraft
systemctl enable MineCraft
