#!/bin/bash -x
#
# Enable necessary services
systemctl -q enable rsyslog
systemctl -q enable sshd
systemctl -q enable cloud-init
systemctl -q enable cloud-config
systemctl -q enable cloud-final
systemctl -q enable cloud-init-local
