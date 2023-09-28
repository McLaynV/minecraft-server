#!/usr/bin/env bash

if [[ "$(whoami)" != root ]]; then
  sudo "${0}" "${@}"
  exit "${?}"
fi

ver_mc=1.20.2
ver_loader=0.14.22
ver_launcher=0.11.2
cron_minutes=30

for param in "${@}"; do
  case param in
    '--help'|'-h'|'help')
      echo "You can use these params (with different values):"
      echo ""
      {
        echo "|--help|Print this help with previously set values (or defaults) and exit."
        echo "|--ver_mc=${ver_mc}|Minecraft version. Check available versions on https://fabricmc.net/use/server/"
        echo "|--ver_loader=${ver_loader}|Fabric loader version. Check available versions on https://fabricmc.net/use/server/"
        echo "|--ver_launcher=${ver_launcher}|Fabric launcher/installer version. Check available versions on https://fabricmc.net/use/server/"
        echo "|--cron_minutes=${cron_minutes}|Number of minutes between regular backups"
      } | column -t -s '|'
      exit 0
      ;;
    '--ver_mc='*)
      mc_ver="$(sed 's/^[^=]=//' <<<"${param}")"
      ;;
    '--ver_loader='*)
      ver_loader="$(sed 's/^[^=]=//' <<<"${param}")"
      ;;
    '--ver_launcher='*)
      ver_launcher="$(sed 's/^[^=]=//' <<<"${param}")"
      ;;
    '--cron_minutes='*)
      cron_minutes="$(sed 's/^[^=]=//' <<<"${param}")"
      if ! [[ "${cron_minutes}" =~ ^[0-9]+$ ]]; then
        echo "Not a number: ${cron_minutes}"
        exit 1
      fi  
      ;;
    *)
      echo "Unsupported parameter: ${param}"
      echo ""
      "${0}" --help
      exit 1
      ;;
  esac
done

cat <<EOF
################################
# Configured params:
# 
# ver_mc=${ver_mc}
# ver_loader=${ver_loader}
# ver_launcher=${ver_launcher}
# cron_minutes=${cron_minutes}
################################
EOF

chmod 750 *.sh
systemctl is-active MineCraft && systemctl stop MineCraft

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
  # no query means failing query
  [[ "${#query[@]}" == 0 ]] && query=(false)
  # install the package if the query fails
  "${query[@]}" 2>/dev/null || "${pac_man}" install "${package}" -y
}
install_package_if_not "git"            git --version
#install_package_if_not "tmux"           tmux -V
install_package_if_not "openjdk-17-jre" java -version
install_package_if_not "python3"        python3 --version
install_package_if_not "curl"           curl --version
install_package_if_not "python3-venv"

# create service user
useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft

# configure git
chown -R minecraft:minecraft /opt/minecraft
server_ip="$(hostname -I | head -n 1)"
sudo -u minecraft git config --global --add safe.directory /opt/minecraft/server
sudo -u minecraft git config --global user.email "server@${server_ip}"
sudo -u minecraft git config --global user.name "server@${server_ip}"
sudo -u minecraft git config credential.helper store

# rcon
# https://wiki.vg/RCON
# barneygale/MCRcon seems not to work - server registers the command but hangs indefinetelly and doesn't return
(
  cd /opt/minecraft/server/rcon-client
  python3 -m venv /opt/minecraft/server/rcon-client
  source /opt/minecraft/server/rcon-client/bin/activate
  python3 -m pip install mcipc
  python3 -m pip install jproperties
)

# crontab for backups
cat                    >/var/spool/cron/crontabs/minecraft <<<"*/${cron_minutes} * * * * /opt/minecraft/server/backup.sh crontab >> /opt/minecraft/server/logs/backup.log"
chown minecraft:crontab /var/spool/cron/crontabs/minecraft
chmod 600               /var/spool/cron/crontabs/minecraft

# firewall - allow service port
if firewall-cmd --version 2>/dev/null; then
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
systemctl enable MineCraft
