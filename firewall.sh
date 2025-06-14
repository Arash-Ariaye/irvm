#!/bin/bash

# IP مجاز که نباید بلاک شود
WHITELIST_IP="91.107.180.29"

# فایل موقت برای ذخیره IP‌های پرترافیک
TEMP_FILE="/tmp/top-ips.txt"

# ایجاد فایل موقت اگر وجود نداشته باشد
touch "$TEMP_FILE" 2>/dev/null || { echo "Error: Cannot create $TEMP_FILE"; exit 1; }

# گرفتن 20 IP با بیشترین ترافیک با tcpdump
sudo tcpdump -i any -nn -c 5000 2>/dev/null | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -20 > "$TEMP_FILE"

# بررسی و بلاک کردن IP‌ها
while read count ip; do
    # بررسی اینکه IP معتبر و غیرمجاز است و تعداد پکت‌ها بیشتر از 1000 است
    if [ "$count" -gt 1000 ] && [ "$ip" != "$WHITELIST_IP" ] && [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Blocking IP $ip with $count packets."

        # بلاک کردن کامل ترافیک ورودی، خروجی و فوروارد برای IP
        sudo iptables -I INPUT -s "$ip" -j DROP
        sudo iptables -I OUTPUT -d "$ip" -j DROP
        sudo iptables -I FORWARD -s "$ip" -j DROP
        sudo iptables -I FORWARD -d "$ip" -j DROP
    fi
done < "$TEMP_FILE"

# پاکسازی فایل موقت
rm -f "$TEMP_FILE"

echo "Script executed. High-traffic IPs blocked."
