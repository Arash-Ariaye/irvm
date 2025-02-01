#!/bin/bash

# List DNS Groups
declare -A dns_groups
dns_groups=(
    ["Google"]="8.8.8.8 8.8.4.4"
    ["Cloudflare"]="1.1.1.1 1.0.0.1"
    ["OpenDNS"]="208.67.222.222 208.67.220.220"
    ["Shecan"]="178.22.122.100 185.51.200.2"
    ["Electro"]="78.157.42.100 78.157.42.101"
    ["RadarGame"]="10.202.10.10 10.202.10.11"
    ["Asiatech"]="79.175.84.1 79.175.84.2"
    ["Shatel"]="217.218.155.155 217.218.127.127"
    ["Parsonline"]="91.99.99.99 91.99.99.98"
)

# Show Main Menu
main_menu() {
    clear
    echo "=============================="
    echo " DNS Server Selector -> IRVM.ORG "
    echo "=============================="
    echo
    echo "Lotfan yeki az goruhaye DNS zir ra entekhab konid:"
    echo "1) DNS haye Irani"
    echo "2) DNS haye Khareji"
    echo "3) Khoruj"
    echo "---------------------------------"
    read -p "Entekhab shoma: " main_choice

    case $main_choice in
        1) dns_menu "Irani" ;;
        2) dns_menu "Khareji" ;;
        3) exit 0 ;;
        *) echo "Entekhab namotabar ast. Lotfan dobare talash konid."; main_menu ;;
    esac
}

# Show DNS Menu
dns_menu() {
    local type=$1
    clear
    echo "=============================="
    echo " DNS Server Selector -> IRVM.ORG "
    echo "=============================="
    echo
    echo "Lotfan yeki az DNS haye $type zir ra entekhab konid:"
    echo "---------------------------------"
    local options=()
    if [ "$type" == "Irani" ]; then
        options=("Shecan" "Electro" "RadarGame" "Asiatech" "Shatel" "Parsonline")
    else
        options=("Google" "Cloudflare" "OpenDNS")
    fi

    select group in "${options[@]}" "Bargasht be menu aslie"; do
        if [[ -n $group ]]; then
            if [ "$group" == "Bargasht be menu aslie" ]; then
                main_menu
                return
            fi
            set_dns $group
            break
        else
            echo "Entekhab namotabar ast. Lotfan dobare talash konid."
        fi
    done
}

# Set DNS
set_dns() {
    local group=$1
    echo -n > /etc/resolv.conf
    for dns in ${dns_groups[$group]}; do
        echo "nameserver $dns" | sudo tee -a /etc/resolv.conf > /dev/null
    done
    clear
    echo "******"
    echo "* DNS haye $group set shodand. *"
    echo "******"
    exit
}

# Start Script
main_menu