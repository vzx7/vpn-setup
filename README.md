# VPN server deployment
The instruction is divided into two manuals. For the server where the VPN will be deployed and for the server on which certificates will be generated. Both manuals are dependent on each other, please study before using.

- [VPN Server](https://github.com/vzx7/vpn-setup/blob/main/vpn_server.md) - VPN Server deployment manual
- [CA Server](https://github.com/vzx7/vpn-setup/blob/main/ca_server.md) - CA Server configuration manual

Instructions are written for Linux servers  - (Debian or Ubuntu).

# Fixing a DNS Leak
If the client is used on a linux operating system and you are using NetworkManager, use [dns_reset.sh](https://github.com/vzx7/vpn-setup/blob/main/dns_reset.sh) script. Otherwise use *script-security 2* scripts in client config.

# Denial of responsibility

These instructions are informative in nature. If you use them, you yourself are solely responsible for the consequences that may arise.

Good luck, be free!
