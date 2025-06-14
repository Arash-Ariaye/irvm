#!/bin/bash

# IP ke moshkeli nadare va bayad az block masoon bashe
WHITELIST_IP="91.107.180.29"

# Ejra-ye tcpdump va gereftan 20 ta IP ba bishtarin packet
sudo tcpdump -i eth0 -nn -c 10000 | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -20 > /tmp/top-ips.txt

# Khandan IP ha va barrasi
while read count ip; do
    # Agar tedad packet bala-ye 1000 bood va IP whitelist nabood
    if [ "$count" -gt 1000 ] && [ "$ip" != "$WHITELIST_IP" ]; then
        echo "Blocking IP $ip ba $count packet."

        # Block kardan voroodi az in IP
        sudo iptables -A INPUT -s $ip -j DROP

        # Block kardan khoroji be in IP
        sudo iptables -A OUTPUT -d $ip -j DROP
    fi
done < /tmp/top-ips.txt

echo "Script ejra shod. IP haye portrafik block shodan."
