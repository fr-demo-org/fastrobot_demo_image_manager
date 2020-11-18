#!/bin/bash -x
#

# Generate basic fstab
cat > /etc/fstab << EOT
#
# /etc/fstab
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
LABEL=root  /         ext4    defaults              0 0
LABEL=tmp   /tmp      ext4    nodev,nosuid,noexec   0 0
/tmp        /var/tmp  none    bind                  0 0
tmpfs       /dev/shm  tmpfs   nodev,nosuid,noexec   0 0

EOT
