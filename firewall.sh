#!/bin/bash

# IP مجاز که نباید بلاک شود
WHITELIST_IP="91.107.180.29"

# اجرای دستور اصلی و پردازش مستقیم خروجی
sudo tcpdump -i eth0 -nn -c 10000 | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -20 | while read count ip; do
    # بررسی اینکه IP معتبر است، غیرمجاز است و تعداد پکت‌ها بیشتر از 1000 است
    if [ "$count" -gt 1000 ] && [ "$ip" != "$WHITELIST_IP" ] && [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Blocking IP $ip with $count packets."

        # بلاک کردن کامل ترافیک ورودی، خروجی و فوروارد برای IP
        sudo iptables -I INPUT -s "$ip" -j DROP
        sudo iptables -I OUTPUT -d "$ip" -j DROP
        sudo iptables -I FORWARD -s "$ip" -j DROP
        sudo iptables -I FORWARD -d "$ip" -j DROP
    fi
done

echo "Script executed. High-traffic IPs blocked."
