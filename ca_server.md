# CA server configuration
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
## (3 step) Set vars
```bash
cd ~/EasyRSA-3.0.8/
cp vars.example vars
nano vars
```
Once the file is opened, paste in the following lines and edit each highlighted value to reflect your own organization info. The important part here is to ensure that you do not leave any of the values blank

set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "NewYork"
set_var EASYRSA_REQ_CITY       "New York City"
set_var EASYRSA_REQ_ORG        "DigitalOcean"
set_var EASYRSA_REQ_EMAIL      "admin@example.com"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"

## (4 step) init pki 
```bash
./easyrsa init-pki
./easyrsa build-ca nopass
```
## (5 step) after 4 step (server.sh) copy server.req
Do it after 7 step (ca_server.md)
```bash
scp sammy@your_server_ip:~/EasyRSA-3.0.8/pki/reqs/server.req /tmp
```

## (6 step) import req
```bash
cd ~/EasyRSA-3.0.8/
./easyrsa import-req /tmp/server.req server
./easyrsa sign-req server server
```

## (7 step) export crt to server
```bash
cd ~/EasyRSA-3.0.8/
scp pki/issued/server.crt sammy@your_server_ip:/tmp
scp pki/ca.crt sammy@your_server_ip:/tmp
```
## (8 step) Import client req from server
after 9 step (vpn_server.md)
```bash
scp sammy@your_server_ip:~/EasyRSA-3.0.8/pki/reqs/client1.req /tmp
```
## (9 step) create client keys
```bash
cd ~/EasyRSA-3.0.8/
./easyrsa import-req /tmp/client1.req client1
./easyrsa sign-req client client1
```
## (10 step) export client crt to server
```bash
scp pki/issued/client1.crt sammy@your_server_ip:/tmp
```