#!/bin/sh

echo '{"pkgs":["plexmediaserver-plexpass","ca_root_nss","nano"]}' > /tmp/pkg.json
iocage create -n "plex" -p /tmp/pkg.json -r 11.3-RELEASE ip4_addr="vnet0|192.168.10.23/24" defaultrouter="192.168.10.1" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json
iocage exec plex "mkdir -p /usr/local/etc/pkg/repos"
cp ./plex-conf/FreeBSD.conf /mnt/tank/iocage/jails/plex/root/usr/local/etc/pkg/repos/FreeBSD.conf
iocage exec plex mkdir -p /config
iocage exec plex mkdir -p /mnt/library
iocage fstab -a plex /mnt/tank/apps/plex /config nullfs rw 0 0
iocage fstab -a plex /mnt/tank/Library /mnt/library nullfs ro 0 0
iocage exec plex chown -R plex:plex /config
iocage exec plex sysrc "plexmediaserver_plexpass_enable=YES"
iocage exec plex sysrc plexmediaserver_plexpass_support_path="/config"
iocage exec plex pkg update -y
iocage exec plex pkg upgrade -y
iocage exec plex chown -R plex:plex /usr/local/share/plexmediaserver-plexpass/
iocage exec plex service plexmediaserver_plexpass start
sleep 20s
echo "Waiting 20s to start"
iocage exec plex service plexmediaserver_plexpass start
iocage exec plex service plexmediaserver_plexpass status
