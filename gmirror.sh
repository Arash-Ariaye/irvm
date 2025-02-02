#!/bin/bash

# JSON file path
json_file="/usr/local/bin/mirror.json"
page_size=10
current_page=1

# Function to set mirror
set_mirror() {
    local url=$1
    local name=$2
    local protocol=$3
    version=$(lsb_release -sr)
    if [[ "$version" < "22.04.1" ]]; then
        sudo sed -i "s|https\?://[^ ]*|$url|g" /etc/apt/sources.list
    else
        sudo sed -i "s|https\?://[^ ]*|$url|g" /etc/apt/sources.list.d/ubuntu.sources
    fi
    clear;
    echo "$(tput setaf 2)mirror ($name - $protocol) set shod.$(tput sgr0)"
    exit;
}

# Function to print table header
print_table_header() {
    printf "$(tput setaf 6)IRVM.ORG$(tput sgr0)\n"
    printf "$(tput setaf 4)+----+---------------------------------------------+---------------+----------+\n"
    printf "$(tput setaf 4)| No | %-43s | %-13s | %-8s |\n" "Keshvar" "Tedad Miror" "Sor'at"
    printf "$(tput setaf 4)+----+---------------------------------------------+---------------+----------+\n"
}

# Function to print table row
print_table_row() {
    printf "$(tput setaf 3)| %-2s | %-43s | %-13s | %-8s |\n" "$1" "$2" "$3" "$4"
    printf "$(tput setaf 3)+----+---------------------------------------------+---------------+----------+\n"
}

# Function to print mirror table header
print_mirror_table_header() {
    printf "$(tput setaf 6)IRVM.ORG$(tput sgr0)\n"
    printf "$(tput setaf 4)+----+---------------------------------------------+---------------+---------------+-----------+\n"
    printf "$(tput setaf 4)| No | %-43s | %-13s | %-13s | %-9s |\n" "Nam Miror" "Sor'at" "Vaziat" "Protokol"
    printf "$(tput setaf 4)+----+---------------------------------------------+---------------+---------------+-----------+\n"
}

# Function to print mirror table row
print_mirror_table_row() {
    printf "$(tput setaf 3)| %-2s | %-43s | %-13s | %-13s | %-9s |\n" "$1" "$2" "$3" "$4" "$5"
    printf "$(tput setaf 3)+----+---------------------------------------------+---------------+---------------+-----------+\n"
}

# Function to paginate results
paginate() {
    local page=$1
    start=$(( ($page - 1) * $page_size ))
    jq -r --argjson start $start --argjson page_size $page_size 'to_entries | .[$start:($start + $page_size)] | .[] | "\(.key)|\(.value.mirrors_count)|\(.value.speed)"' "$json_file"
}

# Function to install jq if not installed
install_jq() {
    echo "$(tput setaf 1)jq not found. Installing jq...$(tput sgr0)"
    sudo apt-get update
    sudo apt-get install -y jq

    # Re-run the script
    exec "$0" "$@"
}

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    install_jq
fi

# Check if mirror.json exists
if [ ! -f "$json_file" ]; then
    echo "$(tput setaf 1)mirror.json not found. Downloading...$(tput sgr0)"
    sudo wget -O "$json_file" "https://raw.githubusercontent.com/Arash-Ariaye/irvm-dns/refs/heads/main/mirror.json"

    # Re-run the script
    exec "$0" "$@"
fi

# Main menu loop
while true; do
    clear;
    echo "che mirror ra mikhahid faal konid?"
    
    # Paginate countries and their details from JSON
    countries=$(paginate $current_page)
    
    # Display country options
    print_table_header
    i=1
    echo "$countries" | while IFS="|" read -r country mirrors_count speed; do
        print_table_row "$i" "$country" "$mirrors_count" "$speed"
        i=$((i + 1))
    done

    if [[ $current_page -gt 1 ]]; then
        echo "$(tput setaf 1)| 0) Exit                  | 8) Page Before            | 9) Next Page$(tput sgr0)"
    else
        echo "$(tput setaf 1)| 0) Exit                  | 9) Next Page$(tput sgr0)"
    fi
    printf "$(tput setaf 1)+----+---------------------------------------------+---------------+----------+\n$(tput sgr0)"
    
    read -p "Lotfan adad ra vared konid (be adad ya khat): " choice

    if [[ "$choice" == "0" ]]; then
        clear;
        break;
    elif [[ "$choice" == "9" ]]; then
        current_page=$((current_page + 1))
        continue
    elif [[ "$choice" == "8" && $current_page -gt 1 ]]; then
        current_page=$((current_page - 1))
        continue
    fi

    # Extract the country name and its details
    country_name=$(jq -r --argjson index $((($current_page - 1) * $page_size + $choice - 1)) 'to_entries | .[$index] | .key' "$json_file")

    if [ -z "$country_name" ]; then
        echo "$(tput setaf 1)Lotfan adad sahih vared konid.$(tput sgr0)"
        sleep 2
        continue
    fi

    clear;
    echo "Lotfan yek makhzan ra entekhab konid:"

    # Extract mirrors for the selected country
    mirrors=$(jq -r '.["'"$country_name"'"].mirrors[] | "\(.mirror_name)|\(.speed_element)|\(.status_element)|\(.link)"' "$json_file")

    # Display mirrors options
    print_mirror_table_header
    i=1
    echo "$mirrors" | while IFS="|" read -r mirror_name speed_element status_element link; do
        protocol=$(echo "$link" | grep -oP '^\w+')
        print_mirror_table_row "$i" "$mirror_name" "$speed_element" "$status_element" "$protocol"
        i=$((i + 1))
    done
    echo "$(tput setaf 1)| 0) Exit                  $(tput sgr0)"
    printf "$(tput setaf 1)+----+---------------------------------------------+---------------+---------------+-----------+\n$(tput sgr0)"
    
    read -p "Lotfan adad ra vared konid (be adad ya khat): " mirror_choice

    if [[ "$mirror_choice" == "0" ]]; then
        clear;
        continue
    fi

    # Extract the selected mirror URL and its details
    mirror_info=$(jq -r --argjson mirror_index $((mirror_choice - 1)) '.["'"$country_name"'"].mirrors[$mirror_index] | "\(.link)|\(.mirror_name)|\(.link | split(":")[0])"' "$json_file")
    IFS='|' read -r mirror_url mirror_name protocol <<< "$mirror_info"

    if [ -z "$mirror_url" ]; then
        echo "$(tput setaf 1)Lotfan adad sahih vared konid.$(tput sgr0)"
        sleep 2
        continue
    fi

    set_mirror "$mirror_url" "$mirror_name" "$protocol"
done
