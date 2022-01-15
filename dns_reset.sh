#!/bin/bash

nmcli -g name,type connection  show  --active | awk -F: '/ethernet|wireless/ { print $1 }' | while read connection
do
  nmcli con mod "$connection" ipv6.ignore-auto-dns yes
  nmcli con mod "$connection" ipv4.ignore-auto-dns yes
  nmcli con mod "$connection" ipv4.dns "8.8.8.8 8.8.4.4"
  nmcli con down "$connection" && nmcli con up "$connection"
done
exit 0
