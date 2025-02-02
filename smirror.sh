#!/bin/bash

clear

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# List of mirrors
mirrors=(
    "https://ubuntu.pishgaman.net/ubuntu"
    "http://mirror.aminidc.com/ubuntu"
    "https://ubuntu.pars.host"
    "https://ir.ubuntu.sindad.cloud/ubuntu"
    "https://ubuntu.shatel.ir/ubuntu"
    "https://ubuntu.mobinhost.com/ubuntu"
    "https://mirror.iranserver.com/ubuntu"
    "https://mirror.arvancloud.ir/ubuntu"
    "http://ir.archive.ubuntu.com/ubuntu"
    "https://ubuntu.parsvds.com/ubuntu/"
    "http://mirror.hidata.org/ubuntu/"
)

# Function to measure download speed
measure_speed() {
    local url=$1
    local output=$(wget --timeout=5 --tries=1 -O /dev/null $url 2>&1 | grep -o '[0-9.]* [KM]B/s' | tail -1)

    if [[ -z $output ]]; then
        echo -1
    else
        if [[ $output == *K* ]]; then
            echo $(echo $output | sed 's/ KB\/s//')
        elif [[ $output == *M* ]]; then
            echo $(echo "scale=2; $(echo $output | sed 's/ MB\/s//') * 1024" | bc)
        fi
    fi
}

# Variables to store the fastest mirror
best_mirror=""
best_speed=0

# Print table header
echo -e "${BLUE}Mirror URL | Download Speed (KB/s)${NC}"
echo -e "--------------------------"

# Check download speed from each mirror
for mirror in "${mirrors[@]}"; do
    speed=$(measure_speed $mirror)
    if [[ $speed == -1 ]]; then
        echo -e "${CYAN}$mirror${WHITE} | ${RED}Failed to connect${NC}"
        continue
    fi

    echo -e "${CYAN}$mirror${WHITE} | ${GREEN}${speed} KB/s${NC}"
    if (( $(echo "$speed > $best_speed" | bc -l) )); then
        best_speed=$speed
        best_mirror=$mirror
    fi
done

# Set the fastest mirror as the default
if [ -n "$best_mirror" ]; then
    echo -e "${BLUE}--------------------------------${NC}"
    echo -e "${GREEN}Fastest mirror found:${NC}"
    echo -e "${CYAN}$best_mirror${WHITE} with speed ${GREEN}$best_speed KB/s${NC}"
    echo -e "${BLUE}--------------------------------${NC}"
    version=$(lsb_release -sr | cut -d '.' -f 1)
    
    # Update sources.list or sources file
    if [[ "$version" -ge 24 ]]; then
        sudo sed -i "s|https\?://[^ ]*|$best_mirror|g" /etc/apt/sources.list.d/ubuntu.sources
    else
        sudo sed -i "s|https\?://[^ ]*|$best_mirror|g" /etc/apt/sources.list
    fi
    sudo apt-get update
else
    echo -e "${RED}No suitable mirror found.${NC}"
fi
