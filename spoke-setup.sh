#!/bin/bash
# Intial setup script
# Tested with Tails 1.4

apt-get update
apt-get install rng-tools -y

echo "HRNGDEVICE=/dev/ttyUSB0" > /etc/default/rng-tools
service rng-tools restart

# Configure Hub
echo -e "\nInsert IP address and netmask of the DMVPN hub tunnel (ex. 10.255.255.1/24): "
read TUNNEL

sed -i 's/to_fill_tunnel/$TUNNEL/g' files/configuration/opennhrp.conf

echo -e "\nInsert IP address or FQDN of the server/router that is the DMVPN hub: "
read HUB_IP

sed -i 's/to_fill_hub/$HUB_IP/g' files/configuration/opennhrp.conf

# Configure Spoke
echo -e "\nInsert IP address and netmask for this spoke (ex. 10.255.255.10/24): "
read SPOKE

sed -i 's/to_fill_tunnel/$SPOKE/g' spoke-start.sh

#Configure secret
echo -e "\nInsert DMVPN authentication string: "
read AUTH

sed -i 's/secret/$AUTH/g' files/configuration/opennhrp.conf

# Create keys
echo "A key and certificate will be created now for this spoke"

openssl genrsa -des3 -out files/certs/key_encrypted.key 4096
openssl rsa -in files/certs/key_encrypted.key -out files/certs/key.pem
openssl req -new -key files/certs/key.pem -out files/certs/cert.csr

echo -e "\nEnd of configuration!\n"
echo "The file ./files/certs/cert.csr will need to be signed using the Root CA key and certificate."
echo "The file name of the certificate should be: cert.pem"
echo "The certificate of the CA will also have to be included in the certs directory. The file should be named ca.pem"