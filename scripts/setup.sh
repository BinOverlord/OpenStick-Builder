#!/bin/sh -e

DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true

echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections
echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections
echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections
rm -f "/etc/locale.gen"

apt update -qqy
apt upgrade -qqy
apt autoremove -qqy

# libconfig runtime package name changes between releases (libconfig9 on
# bookworm, libconfig11 on trixie); resolve it via libconfig-dev
LIBCONFIG=$(apt-cache depends libconfig-dev | sed -n 's/^ *Depends: \(libconfig[0-9][0-9]*\)$/\1/p' | head -n1)
test -n "${LIBCONFIG}"

apt install -qqy --no-install-recommends \
    bridge-utils \
    dnsmasq \
    hostapd \
    iptables \
    ${LIBCONFIG} \
    locales \
    modemmanager \
    netcat-traditional \
    net-tools \
    network-manager \
    openssh-server \
    qrtr-tools \
    rmtfs \
    sudo \
    systemd-timesyncd \
    tzdata \
    wireguard-tools \
    wpasupplicant
apt clean
rm -rf /var/lib/apt/lists/*

passwd -d root

echo user:1::::/home/user:/bin/bash | newusers
echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user
