# !!!Attention, the script cannot be executed. This is a manual!!!
exit 0

# (1 step) To get the latest version, go to the Releases page on the official EasyRSA GitHub project https://github.com/OpenVPN/easy-rsa/releases
#example for EasyRSA-3.0.8

wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
cd ~
tar xvf EasyRSA-3.0.8.tgz
cd EasyRSA-3.0.8/
# (2 step) edit vars
cp vars.example vars

# edit vars. example
nano vars

# Find the settings that set field defaults for new certificates. It will look something like this:

#Uncomment these lines and edit its

#set_var EASYRSA_REQ_COUNTRY    "US"
#set_var EASYRSA_REQ_PROVINCE   "New York"
#set_var EASYRSA_REQ_CITY       "New York City"
#set_var EASYRSA_REQ_ORG        "DigitalOcean"
#set_var EASYRSA_REQ_EMAIL      "admin@example.com"
#set_var EASYRSA_REQ_OU         "Community"

# (3 step) init pki 
./easyrsa init-pki

# (4 step) build ca
./easyrsa build-ca nopass

# (5 step) after 4 step (server.sh) copy server.req
scp sammy@your_server_ip:~/EasyRSA-3.0.8/pki/reqs/server.req /tmp

# (6 step) import req
cd EasyRSA-3.0.8/
./easyrsa import-req /tmp/server.req server
./easyrsa sign-req server server

# (7 step) export crt to server
scp pki/issued/server.crt sammy@your_server_ip:/tmp
scp pki/ca.crt sammy@your_server_ip:/tmp

# (8 step) after 9 step (server.sh) import client req from server
scp sammy@your_server_ip:~/EasyRSA-3.0.8/pki/reqs/client1.req /tmp
cd EasyRSA-3.0.8/

# (9 step) create client keys
./easyrsa import-req /tmp/client1.req client1
./easyrsa sign-req client client1

# (10 step) export client crt to server
scp pki/issued/client1.crt sammy@your_server_ip:/tmp









