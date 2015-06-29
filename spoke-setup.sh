#!/bin/bash
# Intial setup script
# Tested with Tails 1.4

# Configure serial interface
stty -F /dev/ttyUSB0 19200 clocal cs8 -cstopb -parenb

#Install rng-tools and configure RNG
apt-get update
apt-get install rng-tools -y

cp files/configuration/rng-tools /etc/default/rng-tools
service rng-tools restart

# Download build tools and dependecies
apt-get install build-essential libc-ares-dev pkg-config -y

# Download and compile OpenNHRP
wget http://downloads.sourceforge.net/project/opennhrp/opennhrp/opennhrp-0.14.1.tar.bz2
tar xf opennhrp-0.14.1.tar.bz2
cd opennhrp-0.14.1
make
cd ..
rm opennhrp-0.14.1.tar.bz2

# Configure Hub
echo -e "\nInsert IP address of the hub tunnel interface (ex. 10.255.255.1): \c"
read TUNNEL_HUB_IP

sed -i "s/TUNNEL_HUB_IP/$TUNNEL_HUB_IP/g" files/configuration/opennhrp.conf

echo -e "\nInsert IP address of the server/router that is the DMVPN hub: \c"
read HUB_IP

sed -i "s/HUB_IP/$HUB_IP/g" files/configuration/opennhrp.conf

# Configure Spoke
echo -e "\nInsert IP address for this spoke tunnel interface (ex. 10.255.255.10): \c"
read TUNNEL_SPOKE_IP

sed -i "s/TUNNEL_SPOKE_IP/$TUNNEL_SPOKE_IP/g" spoke-start.sh

# Configure netmask
echo -e "\nInsert netmask of the tunnel network (ex. 24): \c"
read TUNNEL_NETMASK

sed -i "s/TUNNEL_NETMASK/$TUNNEL_NETMASK/g" files/configuration/opennhrp.conf
sed -i "s/TUNNEL_NETMASK/$TUNNEL_NETMASK/g" spoke-start.sh

#Configure secret
echo -e "\nInsert DMVPN authentication string: \c"
read SECRET

sed -i "s/SECRET/$SECRET/g" files/configuration/opennhrp.conf

# Create keys
echo -e "\nA key and certificate will be created now for this spoke\n"

openssl genrsa -des3 -out key_encrypted.key 4096
openssl rsa -in key_encrypted.key -out key.pem
openssl req -new -key key.pem -out cert.csr

mkdir -p files/certs
mv key.pem files/certs/key.pem
mv cert.csr files/certs/cert.csr
rm key_encrypted.key

echo -e "\nEnd of configuration!\n"
echo "The file ./files/certs/cert.csr will need to be signed using the Root CA key and certificate."
echo "The file name of the certificate should be: cert.pem"
echo -e "The certificate of the CA will also have to be included in the certs directory. The file should be named ca.pem\n"