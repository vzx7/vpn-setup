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
# Remove the “#” character from the beginning of the line to uncomment this setting
# net.ipv4.ip_forward=1
sudo sysctl -p












