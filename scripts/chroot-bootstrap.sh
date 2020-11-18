#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

# Update APT with new sources
apt-get update

# Do not configure grub during package install
echo 'grub-pc grub-pc/install_devices_empty select true' | debconf-set-selections
echo 'grub-pc grub-pc/install_devices select' | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive

# Install various packages needed for a booting system
apt-get install -y linux-aws grub-pc gdisk

cat << EOF > /etc/default/locale
LANG="C.UTF-8"
LC_CTYPE="C.UTF-8"
EOF

# Install OpenSSH
apt-get install -y --no-install-recommends openssh-server

# Install GRUB
# shellcheck disable=SC2016
grub-probe /
grub-install /dev/xvdf

# Configure and update GRUB
mkdir -p /etc/default/grub.d
cat << EOF > /etc/default/grub.d/50-aws-settings.cfg
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0 ip=dhcp tsc=reliable net.ifnames=0"
GRUB_TERMINAL=console
EOF

update-grub

# Set options for the default interface
#cat << EOF > /etc/network/interfaces.d/50-cloud-init.cfg
#auto lo
#iface lo inet loopback
#
#auto eth0
#iface eth0 inet dhcp
#EOF

cat << EOF > /etc/netplan/eth0.yaml
network:
 version: 2
 ethernets:
   eth0:
     dhcp4: true
EOF

# Install standard packages (python is for ebsnvme-id)
apt-get install -y ubuntu-standard \
	cloud-init \
	python

bash -x /tmp/chroot-scripts/20-config.sh
bash -x /tmp/chroot-scripts/30-services.sh
bash -x /tmp/chroot-scripts/50-cloud-init.sh

