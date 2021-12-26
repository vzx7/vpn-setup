# !!!Attention, the script cannot be executed. This is a manual!!!
exit 0

# (1 step) deploy openVpn server

sudo apt update && apt install openvpn

# (2 step) To get the latest version, go to the Releases page on the official EasyRSA GitHub project https://github.com/OpenVPN/easy-rsa/releases
#example for EasyRSA-3.0.8

wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
cd ~
tar xvf EasyRSA-3.0.8.tgz
cd EasyRSA-3.0.8/

# (3 step) init 
./easyrsa init-pki
#Be sure to include the nopass option as well. Failing to do so will password-protect the request file which could lead to permissions issues later on

# (4 step) create server crt 
./easyrsa gen-req server nopass
sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/

# (5 step) after 7 step (CA_Cwnter_PC.sh), copy crt 
sudo cp /tmp/{server.crt,ca.crt} /etc/openvpn/

cd EasyRSA-3.0.8/
# (6 step) create a strong Diffie-Hellman key
./easyrsa gen-dh

# (7 step) generate an HMAC signature to strengthen the server’s TLS integrity verification capabilities
openvpn --genkey tls-auth ta.key

# (8 step) copy keys
sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/
sudo cp ~/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/

# (9 step) Generating a Client Certificate and Key Pair
# example client1
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
cd ~/EasyRSA-3.0.8/
./easyrsa gen-req client1 nopass
cp pki/private/client1.key ~/client-configs/keys/

# (10 step) after 10 step (CA_Cwnter_PC.sh)
cp /tmp/client1.crt ~/client-configs/keys/
cp ~/EasyRSA-3.0.8/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/

# (11 step) - Configuring the OpenVPN Service
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
sudo nano /etc/openvpn/server.conf

# (11 step) configuration set:
# remove the “;” to uncomment it or add rule

# tls-auth ta.key 0 
# cipher AES-256-CBC
# auth SHA256
# dh dh.pem
# user nobody
# group nogroup
# push "redirect-gateway def1 bypass-dhcp"
# push "dhcp-option DNS 208.67.222.222"
# push "dhcp-option DNS 208.67.220.220"
# proto udp4
# mssfix 0

# (12 step) Adjusting the Server Networking Configuration
sudo nano /etc/sysctl.conf

# (13 step) Remove the “#” character from the beginning of the line to uncomment this setting
# net.ipv4.ip_forward=1
sudo sysctl -p

# (14 step) Setup UFW (optional) get interface
ip route | grep default
# Output example: default via 203.0.113.1 dev eth0 proto static. this result shows the interface named "eth0"

# (15 step) edit before rules
sudo nano /etc/ufw/before.rules

# Add rules to the beginning of the file, remove the "#" sign. Replace 'eth0' with your interface.

#*nat
#:POSTROUTING ACCEPT [0:0]
#-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
#COMMIT

# (16 step) find the DEFAULT_FORWARD_POLICY directive and change the value from DROP to ACCEPT
sudo nano /etc/default/ufw

# example
#DEFAULT_FORWARD_POLICY="ACCEPT"
# remove tunnel detection (two-way ping) in VPN
# add rules for icmp
#-A ufw-before-input -p icmp --icmp-type echo-request -j DROP

# (17 step) add rules for udp and OpenSSH
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH
sudo ufw disable
sudo ufw enable

# (18 step) Starting and Enabling the OpenVPN Service
sudo systemctl start openvpn@server
# check status
sudo systemctl status openvpn@server
# permanent start
sudo systemctl enable openvpn@server

# (19 steps) Creating the Client Configuration Infrastructure
mkdir -p ~/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf

# (20 step) edit client rules
nano ~/client-configs/base.conf

# edit and remove "#"
# remote your_server_ip 1194
# proto udp4
# user nobody
# group nogroup

# Find the directives that set the ca, cert, and key. Comment out these directives since you will add the certs and keys within the file itself shortly
# #ca ca.crt
# #cert client.crt
# #key client.key

# Similarly, comment out the tls-auth directive, as you will add ta.key directly into the client configuration file:
# #tls-auth ta.key 1

# Mirror the cipher and auth settings that you set in the /etc/openvpn/server.conf file
# cipher AES-256-CBC
# auth SHA256

# Next, add the key-direction directive somewhere in the file. You must set this to “1” for the VPN to function correctly on the client machine
# key-direction 1

# Finally, add a few commented out lines to handle various methods that Linux based VPN clients will use for DNS resolution. You’ll add two similar, but separate sets of commented out lines. The first set is for clients that do not use systemd-resolved to manage DNS. These clients rely on the resolvconf utility to update DNS information for Linux clients

#; script-security 2
#; up /etc/openvpn/update-resolv-conf
#; down /etc/openvpn/update-resolv-conf

# Now add another set of lines for clients that use systemd-resolved for DNS resolution:

#; script-security 2
#; up /etc/openvpn/update-systemd-resolved
#; down /etc/openvpn/update-systemd-resolved
#; down-pre
#; dhcp-option DOMAIN-ROUTE .

# (21 step) move a script "make_client_config.sh" to ~/client-configs/
# add x rule for the sript
chmod 700 ~/client-configs/make_client_config.sh

# (22 step) Generating Client Configurations for "client1"
cd ~/client-configs
sudo ./make_config.sh client1
ls ~/client-configs/files
# Output: client1.ovpn

# (23 step) You need to transfer this file to the device you plan to use as the client.
sftp sammy@your_server_ip:client-configs/files/client1.ovpn ~/

# use openvpn3
# https://openvpn.net/cloud-docs/openvpn-3-client-for-linux/

























