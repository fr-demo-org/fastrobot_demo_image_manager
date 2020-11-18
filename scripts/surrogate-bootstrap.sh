#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

export DEBIAN_FRONTEND=noninteractive

# Copy Amazon Sources to /etc/apt/sources
cp /tmp/sources.list /etc/apt/sources.list

# Update apt and install required packages
/bin/echo 'Make sure debootstrap and gdisk are installed on builder'
apt-get update
sleep 10
apt-get install -y debootstrap
apt-get install -y gdisk

# Partition the new root EBS volume
/bin/echo 'Partition EBS Volume'
sudo sgdisk -og $DEVICE
sudo sgdisk -n 1:4198400:0 -c 1:\"Linux\" -t 1:8300 $DEVICE
sudo sgdisk -n 2:4096:4198399 -c 1:\"Linux\" -t 1:8300 $DEVICE
sudo sgdisk -n 128:2048:4095 -c 128:\"BIOS_Boot_Partition\" -t 128:ef02 $DEVICE

# Create Filesystems
/bin/echo 'Create desired filesystem'
sudo mkfs.$FS_TYPE -L root ${DEVICE}1
sudo mkfs.$FS_TYPE -L tmp ${DEVICE}2
sudo sync

# Mount our new Root Filesystem xvdaf1 onto /mnt
/bin/echo 'Mount new Root Filesystem onto /mnt'
sudo mount ${DEVICE}1 /mnt

# Bootstrap Ubuntu into /mnt
/bin/echo 'Bootstrap Ubuntu into /mnt'
debootstrap --arch amd64 ${CODENAME} /mnt
cp /tmp/sources.list /mnt/etc/apt/sources.list

# Create mount points and mount the filesystem
mkdir -p /mnt/{dev,proc,sys}
mount --rbind /dev /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys /mnt/sys

# Copy files needed for the chroot bootstrap
#cp /tmp/05-logging.cfg /mnt/tmp/05-logging.cfg
#cp /tmp/10-growpart.cfg /mnt/tmp/10-growpart.cfg
cp /tmp/cloud.cfg /mnt/tmp/cloud.cfg

# Copy the scripts for the chroot
cp -r /tmp/chroot-scripts /mnt/tmp/

# Copy the bootstrap script into place and execute inside chroot
cp /tmp/chroot-bootstrap.sh /mnt/tmp/chroot-bootstrap.sh
chmod +x /mnt/tmp/chroot-bootstrap.sh
chroot /mnt /tmp/chroot-bootstrap.sh
rm -f /mnt/tmp/chroot-bootstrap.sh

# Copy the nvme identification script into /sbin inside the chroot
mkdir -p /mnt/sbin
cp /tmp/ebsnvme-id /mnt/sbin/ebsnvme-id
chmod +x /mnt/sbin/ebsnvme-id

# Copy the udev rules for identifying nvme devices into the chroot
mkdir -p /mnt/etc/udev/rules.d
cp /tmp/70-ec2-nvme-devices.rules \
	/mnt/etc/udev/rules.d/70-ec2-nvme-devices.rules

# Remove temporary sources list - CloudInit regenerates it
rm -f /mnt/etc/apt/sources.list

# This could perhaps be replaced (more reliably) with an `lsof | grep -v /mnt` loop,
# however in approximately 20 runs, the bind mounts have not failed to unmount.
sleep 10

# Unmount bind mounts
umount -l /mnt/dev
umount -l /mnt/proc
umount -l /mnt/sys
