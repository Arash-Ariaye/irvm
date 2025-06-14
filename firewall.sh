#!/bin/bash

# IP server khodet
MY_IP="91.107.180.29"

# File movaghat baraye zakhire IP-ha
TMP_IP_FILE="/tmp/blocked_ips.txt"

echo "[+] Dar hale jam'avari IP-ha..."
IP_LIST=$(sudo tcpdump -i eth0 -nn -c 10000 | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -20 | awk '{print $2}' | grep -v "$MY_IP")

# Neveshtane IP-ha dar file movaghat
echo "$IP_LIST" > "$TMP_IP_FILE"

echo "[+] Dar hale block kardan-e IP-ha..."
for IP in $IP_LIST; do
    sudo iptables -A INPUT -s $IP -j DROP
    sudo iptables -A OUTPUT -d $IP -j DROP
done

# Save kardan rules
sudo netfilter-persistent save

echo "[+] IP-ha block shodan. montazer 24 saat mimunim..."

# Entezar 24 saat (86400 saniye)
sleep 86400

echo "[+] Dar hale hazf kardan-e rules..."
for IP in $(cat "$TMP_IP_FILE"); do
    sudo iptables -D INPUT -s $IP -j DROP
    sudo iptables -D OUTPUT -d $IP -j DROP
done

# Save kardan rules baraye marhale payani
sudo netfilter-persistent save

# Paak kardan file movaghat
rm -f "$TMP_IP_FILE"

echo "[✓] Hame chiz pak shod!"
