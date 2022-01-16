# Server configuration
## (1 step) Installing dependencies on the server
```bash
sudo apt update
sudo apt install openvpn easy-rsa
```
## (2 step) Installing last version EasyRSA
To get the latest version, go to the Releases page on the official [EasyRSA](https://github.com/OpenVPN/easy-rsa/releases) GitHub project.
Now last version EasyRSA - 3.0.8
```bash
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
cd ~
tar xvf EasyRSA-3.0.8.tgz
```
## (3 step) Init pki
Run this script with the init-pki option to initiate the public key infrastructure
```bash
cd ~/EasyRSA-3.0.8/
./easyrsa init-pki
```
## (4 step) create server crt
Be sure to include the nopass option as well. Failing to do so will password-protect the request file which could lead to permissions issues later on
```bash
./easyrsa gen-req server nopass
sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/
```
## (5 step) copy crt
Do it after 7 step (ca_server.md)
```bash
sudo cp /tmp/{server.crt,ca.crt} /etc/openvpn/
```
## (6 step) generate the server’s TLS integrity verification capabilities

```bash
openvpn --genkey tls-auth ta.key
sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/
```

## (7 step) Generating a Client Certificate and Key Pair
Example for client1
```bash
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
cd ~/EasyRSA-3.0.8/
./easyrsa gen-req client1 nopass
cp pki/private/client1.key ~/client-configs/keys/
```
## (8 step) 
After 10 step (ca_server.md)
```bash
cp /tmp/client1.crt ~/client-configs/keys/
cp ~/EasyRSA-3.0.8/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/
```
## (9 step) - Configuring the OpenVPN Service
```bash
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
sudo nano /etc/openvpn/server.conf
```
remove the “;” to uncomment it or add rules:
```
port 1194 # port 443
proto udp4 # or proto tcp (if you use port 443)
tls-auth ta.key 0 
;cipher AES-256-CBC
cipher AES-256-GCM
auth SHA256
dh none
user nobody
group nogroup
```

If you wish to use the VPN to route all of your client traffic over the VPN, you will likely want to push some extra settings to the client computers.
```
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 208.67.222.222"
push "dhcp-option DNS 208.67.220.220"
```
Remove vpn fingerprint:
```
mssfix 0
```
## (10 step) Adjusting the Server Networking Configuration
```bash
sudo nano /etc/sysctl.conf
```
Remove the “#” character from the beginning of the line to uncomment this setting "net.ipv4.ip_forward=1" and recheck.

```bash
sudo sysctl -p
```
## (11 step) Setup UFW (optional) get interface
```bash
ip route | grep default
```
Output example: default via 203.0.113.1 dev eth0 proto static. this result shows the interface named "eth0"
```bash
sudo nano /etc/ufw/before.rules
```
Add rules to the beginning of the top file. Replace 'eth0' with your interface

```
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
```
In file /etc/default/ufw find the DEFAULT_FORWARD_POLICY directive and change the value from DROP to ACCEPT.
```
DEFAULT_FORWARD_POLICY="ACCEPT"
```
Remove tunnel detection (two-way ping) in VPN
Add rules for icmp.
```bash
-A ufw-before-input -p icmp --icmp-type echo-request -j DROP
```
## (12 step) add rules for udp and OpenSSH
```bash
sudo ufw allow 1194/udp # or 443/tcp 
sudo ufw allow OpenSSH
sudo ufw disable
sudo ufw enable
```
## (13 step) Starting OpenVPN
```bash
sudo systemctl -f enable openvpn-server@server.service
sudo systemctl start openvpn-server@server.service
sudo systemctl status openvpn-server@server.service
```
## (14 steps) Creating the Client Configuration Infrastructure
```bash
mkdir -p ~/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
nano ~/client-configs/base.conf
```
Inside, locate the remote directive. This points the client to your OpenVPN server address — the public IP address of your OpenVPN server. If you decided to change the port that the OpenVPN server is listening on, you will also need to change 1194 to the port you selected.
```bash
remote your_server_ip 1194 # or port 443
proto udp4 # or proto tcp (if you use port 443)
user nobody
group nogroup
cipher AES-256-GCM
auth SHA256
mssfix 0
key-direction 1
# Comment out these directives since you will add the certs and keys within the file itself shortly
;ca ca.crt
;cert client.crt
;key client.key
# Similarly, comment out the tls-auth directive, as you will add ta.key directly into the client configuration file
;tls-auth ta.key 1
# The first set is for clients that do not use systemd-resolved to manage DNS. These clients rely on the resolvconf utility to update DNS information for Linux clients
; script-security 2
; up /etc/openvpn/update-resolv-conf
; down /etc/openvpn/update-resolv-conf
# Now add another set of lines for clients that use systemd-resolved for DNS resolution
; script-security 2
; up /etc/openvpn/update-systemd-resolved
; down /etc/openvpn/update-systemd-resolved
; down-pre
; dhcp-option DOMAIN-ROUTE .
```
## (15 step) move a script "make_client_config.sh" to ~/client-configs/
Add execute rule for the sript
change 1194 to the port you selected.
```bash
chmod 700 ~/client-configs/make_client_config.sh
```
## (16 step) Generating Client Configurations for "client1"
```bash
cd ~/client-configs
sudo ./make_config.sh client1
ls ~/client-configs/files
```
Output: client1.ovpn
## (17 step) You need to transfer this file to the device you plan to use as the client
```bash
sftp sammy@your_server_ip:client-configs/files/client1.ovpn ~/
```

Use openvpn3: https://openvpn.net/cloud-docs/openvpn-3-client-for-linux/