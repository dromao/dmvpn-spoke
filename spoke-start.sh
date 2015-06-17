#!/bin/bash
# Deployment script
# Tested with Tails 1.4

apt-get update
apt-get install rng-tools -y

echo "HRNGDEVICE=/dev/ttyUSB0" > /etc/default/rng-tools

# Install OpenNHRP package (Dependencies are automatically installed as well)
dpkg -i files/opennhrp/opennhrp_0.14.1-1_amd64.deb

# Copy configuration files
cp files/configuration/opennhrp.conf /etc/opennhrp/opennhrp.conf
cp files/configuration/racoon.conf /etc/racoon/racoon.conf
cp files/configuration/ipsec-tools.conf /etc/ipsec-tools.conf

# Copy keys' directory
cp -r files/certs /etc/racoon/certs

# Load GRE kernel module
modprobe ip_gre

# Create GRE interface
ip tunnel add gre1 mode gre key 1234 ttl 64
ip addr add to_fill_tunnel dev gre1
ip link set gre1 up

# Restart services
service rng-tools restart
service racoon restart
service setkey restart

# Start OpenNHRP
/usr/sbin/opennhrp -d

echo "Completed!"