#!/bin/bash

set_mirror() {
    local url=$1
    local name=$2
    version=$(lsb_release -sr)
    if [[ "$version" < "22.04.1" ]]; then
        sed -i "s|https\?://[^ ]*|$url|g" /etc/apt/sources.list
    else
        sed -i "s|https\?://[^ ]*|$url|g" /etc/apt/sources.list.d/ubuntu.sources
    fi
    clear;
    echo "mirror ($name) set shod."
    exit;
}

while true; do
    clear;
    echo "che mirror ra mikhahid faal konid?"
    echo "  1) mirror gheyr rasmi (mesl shatel - pishgaman ...)"
    echo "  2) ir.ubuntu.com (IRAN)"
    echo "  3) de.ubunto.com (Germani)"
    echo "  0) exit"
    read -p "Lotfan adad beyn 0 ta 3 ra vared konid: " mirror_choice
    if [[ "$mirror_choice" =~ ^[0-3]$ ]]; then
        clear;
        case "$mirror_choice" in
            1)
                while true; do
                    echo "Lotfan yek makhzan ra entekhab konid:"
                    echo "  1) pishgaman.net"
                    echo "  2) aminidc.com"
                    echo "  3) pars.host"
                    echo "  4) sindad.cloud"
                    echo "  5) faraso.org"
                    echo "  6) shatel.ir"
                    echo "  7) mobinhost.com"
                    echo "  8) hostiran.ir"
                    echo "  9) 0-1.cloud"
                    echo "  10) iranserver.com"
                    echo "  11) arvancloud.ir"
                    echo "0) *exit*"
                    read -p "   Lotfan adad 1 ta 11 ra vared konid: " repo_choice

                    if [ "$repo_choice" -ge 0 ] && [ "$repo_choice" -le 11 ]; then
                        case "$repo_choice" in
                            1) set_mirror "https://ubuntu.pishgaman.net/ubuntu" "pishgaman" ;;
                            2) set_mirror "http://mirror.aminidc.com/ubuntu" "amindc" ;;
                            3) set_mirror "https://ubuntu.pars.host" "pars.host" ;;
                            4) set_mirror "https://ir.ubuntu.sindad.cloud/ubuntu" "sindad" ;;
                            5) set_mirror "http://mirror.faraso.org/ubuntu" "faraso" ;;
                            6) set_mirror "https://ubuntu.shatel.ir/ubuntu" "shatel" ;;
                            7) set_mirror "https://ubuntu.mobinhost.com/ubuntu" "mobinhost" ;;
                            8) set_mirror "https://ubuntu.hostiran.ir/ubuntuarchive" "hostiran" ;;
                            9) set_mirror "https://mirror.0-1.cloud/ubuntu" "0-1" ;;
                            10) set_mirror "https://mirror.iranserver.com/ubuntu" "iranserver" ;;
                            11) set_mirror "https://mirror.arvancloud.ir/ubuntu" "arvancloud" ;;
                            0) clear; break;;
                        esac
                    else
                        echo "Lotfan adad sahih vared konid."
                    fi
                done
                ;;
            2) set_mirror "http://ir.archive.ubuntu.com/ubuntu" "iran" ;;
            3) set_mirror "http://de.archive.ubuntu.com/ubuntu" "Germani" ;;
            0) clear; break ;;
        esac
        break
    else
        echo "Lotfan adad sahih vared konid."
    fi
done
