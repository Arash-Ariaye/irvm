#!/bin/bash

# 白名单IP，不会被封锁
WHITELIST_IP="91.107.180.29"

# 直接从tcpdump输出中读取前20个高流量IP
sudo tcpdump -i any -nn -c 5000 2>/dev/null | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -20 | while read count ip; do
    # 检查IP是否有效、不是白名单IP且数据包数超过1000
    if [ "$count" -gt 1000 ] && [ "$ip" != "$WHITELIST_IP" ] && [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Blocking IP $ip with $count packets."

        # 完全封锁该IP的输入、输出和转发流量
        sudo iptables -I INPUT -s "$ip" -j DROP
        sudo iptables -I OUTPUT -d "$ip" -j DROP
        sudo iptables -I FORWARD -s "$ip" -j DROP
        sudo iptables -I FORWARD -d "$ip" -j DROP
    fi
done

echo "Script executed. High-traffic IPs blocked."
