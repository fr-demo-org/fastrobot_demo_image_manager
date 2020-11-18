#!/bin/bash -x
#
# Update APT with new sources
apt-get update

# Do not configure grub during package install
echo 'grub-pc grub-pc/install_devices_empty select true' | debconf-set-selections
echo 'grub-pc grub-pc/install_devices select' | debconf-set-selections

# Install various packages needed for a booting system
apt-get install -y linux-aws grub-pc gdisk

# Install OpenSSH
apt-get install -y --no-install-recommends openssh-server

# Install standard packages (python is for ebsnvme-id)
apt-get install -y ubuntu-standard \
	cloud-init \
	python

# Install addtional packages here
apt-get install -y awscli
snap install amazon-ssm-agent --classic
