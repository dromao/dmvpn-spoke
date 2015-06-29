#!/bin/bash
# Deployment script
# Tested with Tails 1.4

export DEBIAN_FRONTEND=noninteractive

# Configure serial interface
stty -F /dev/ttyUSB0 19200 clocal cs8 -cstopb -parenb

#Install rng-tools and configure RNG
apt-get update
apt-get install rng-tools -y

cp files/configuration/rng-tools /etc/default/rng-tools
service rng-tools restart

# Install dependencies and build tools
apt-get install racoon ipsec-tools build-essential libc-ares-dev pkg-config -y

# Install OpenNHRP
cd opennhrp-0.14.1
make install
cd ..

# Copy configuration files
cp files/configuration/opennhrp.conf /etc/opennhrp/opennhrp.conf
cp files/configuration/racoon.conf /etc/racoon/racoon.conf
cp files/configuration/ipsec-tools.conf /etc/ipsec-tools.conf
cp files/configuration/ferm.conf /etc/ferm/ferm.conf

# Copy keys' directory
cp files/certs/* /etc/racoon/certs/

# Load GRE kernel module
modprobe ip_gre

# Create GRE interface
ip tunnel add gre1 mode gre key 1234 ttl 64
ip addr add TUNNEL_SPOKE_IP/TUNNEL_NETMASK dev gre1
ip link set gre1 up

# Restart services
service rng-tools restart
service racoon restart
service setkey restart
service ferm restart

# Start OpenNHRP
/usr/sbin/opennhrp -d

echo -e "\nCompleted!\n"
