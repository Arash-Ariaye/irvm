#!/bin/bash

# Your own server IP
myip="91.107.180.29"

# Network interface
iface="eth0"

# Packet capture and process
tcpdump -i $iface -nn -c 10000 | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | awk '$1>500 {print $2}' | while read ip
do
  # Skip own IP
  if [ "$ip" != "$myip" ]; then
    echo "Blackholing $ip..."
    ip route add blackhole $ip
  fi
done
