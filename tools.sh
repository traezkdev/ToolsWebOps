#!/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Header
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
 _______             ______            _     
|__   __|           |  ____|          | |    
   | |_ __ ___  ___ | |__ ___  ___  __| |___ 
   | | '__/ _ \/ _ \|  __/ _ \/ _ \/ _` / __|
   | | | |  __/ (_) | | |  __/  __/ (_| \__ \
   |_|_|  \___|\___/|_|  \___|\___|\__,_|___/

               TraezkDev Toolkit
               Author: Alfin
EOF
echo -e "${NC}${CYAN}  Legal & Professional WebOps Bash Tools${NC}"
echo ""

# Auto install helper
function check_and_install() {
    tool=$1
    pkg_name=$2
    if ! command -v $tool &>/dev/null; then
        echo -e "${RED}[!] $tool belum terinstal.${NC}"
        echo -e "${CYAN}Ingin menginstal $pkg_name sekarang?${NC}"
        read -p "Install $pkg_name? (y/n): " jawab
        if [[ "$jawab" == "y" ]]; then
            echo -e "${GREEN}Menginstal $pkg_name...${NC}"
            sudo apt update && sudo apt install -y "$pkg_name"
            clear
            if ! command -v $tool &>/dev/null; then
                echo -e "${RED}[!] Gagal menginstal $pkg_name. Silakan install manual.${NC}"
                pause_continue
                return 1
            fi
        else
            echo -e "${RED}$tool dibutuhkan untuk fitur ini.${NC}"
            pause_continue
            return 1
        fi
    fi
    return 0
}

# Menu utama
function show_menu() {
    echo -e "${GREEN}[1]${NC} Ping Test"
    echo -e "${GREEN}[2]${NC} DNS Lookup"
    echo -e "${GREEN}[3]${NC} Whois Lookup"
    echo -e "${GREEN}[4]${NC} Traceroute"
    echo -e "${GREEN}[5]${NC} Port Scan (top 100)"
    echo -e "${GREEN}[6]${NC} HTTP Headers Check"
    echo -e "${GREEN}[7]${NC} SSL Certificate Info"
    echo -e "${GREEN}[8]${NC} Subdomain Brute (Simple)"
    echo -e "${GREEN}[9]${NC} Website Status Check (Detail)"
    echo -e "${GREEN}[10]${NC} Page Load Time"
    echo -e "${GREEN}[11]${NC} MX Record Check"
    echo -e "${GREEN}[12]${NC} CDN Detection"
    echo -e "${GREEN}[13]${NC} CMS Detection (Basic)"
    echo -e "${GREEN}[14]${NC} Reverse DNS Lookup"
    echo -e "${GREEN}[0]${NC} Exit"
    echo ""
}

function ask_target() {
    read -p "Enter domain or IP: " target
}

function pause_continue() {
    echo ""
    read -p "Do you want to return to menu? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "${RED}Exiting...${NC}"
        exit 0
    fi
    clear
}

function subdomain_brute() {
    check_and_install "dig" "dnsutils" || return
    ask_target
    if [ ! -f subdomains.txt ]; then
        echo -e "${RED}[!] subdomains.txt wordlist not found.${NC}"
        return
    fi
    echo -e "${CYAN}Scanning subdomains for $target...${NC}"
    while read sub; do
        full="$sub.$target"
        result=$(dig +short "$full")
        [[ $result != "" ]] && echo -e "${GREEN}[+] $full -> $result${NC}"
    done < subdomains.txt
}

function ssl_info() {
    check_and_install "openssl" "openssl" || return
    ask_target
    echo -e "${CYAN}Fetching SSL certificate info for $target...${NC}"
    echo | openssl s_client -connect "$target:443" 2>/dev/null | openssl x509 -noout -issuer -subject -dates
}

function port_scan() {
    check_and_install "nmap" "nmap" || return
    ask_target
    echo -e "${CYAN}Menjalankan port scan top 100 ports di $target...${NC}"
    nmap --top-ports 100 "$target"
}

function traceroute_scan() {
    check_and_install "traceroute" "traceroute" || return
    ask_target
    echo -e "${CYAN}Menjalankan traceroute ke $target...${NC}"
    traceroute "$target"
}

function mx_check() {
    check_and_install "dig" "dnsutils" || return
    ask_target
    echo -e "${CYAN}MX records for $target:${NC}"
    dig "$target" MX +short
}

function cdn_detect() {
    check_and_install "dig" "dnsutils" || return
    check_and_install "whois" "whois" || return
    ask_target
    ip=$(dig +short "$target" | tail -n1)
    echo -e "${CYAN}IP for $target: $ip${NC}"
    org=$(whois "$ip" | grep -iE "OrgName|Organization" | head -1)
    echo -e "${CYAN}Org Info: $org${NC}"
    if echo "$org" | grep -iq "Cloudflare"; then
        echo -e "${GREEN}[+] Cloudflare detected${NC}"
    elif echo "$org" | grep -iq "Google"; then
        echo -e "${GREEN}[+] Google infrastructure${NC}"
    elif echo "$org" | grep -iq "Akamai"; then
        echo -e "${GREEN}[+] Akamai CDN detected${NC}"
    elif echo "$org" | grep -iq "Fastly"; then
        echo -e "${GREEN}[+] Fastly CDN detected${NC}"
    elif echo "$org" | grep -iq "Amazon"; then
        echo -e "${GREEN}[+] Amazon Cloud/CDN detected${NC}"
    else
        echo -e "${RED}[-] CDN provider not clearly identified${NC}"
    fi
}

function cms_detect() {
    check_and_install "curl" "curl" || return
    ask_target
    echo -e "${CYAN}Checking for CMS on $target...${NC}"
    html=$(curl -sL "https://$target")
    if echo "$html" | grep -iq "wp-content"; then
        echo -e "${GREEN}[+] WordPress Detected${NC}"
    elif echo "$html" | grep -iq "Joomla!"; then
        echo -e "${GREEN}[+] Joomla Detected${NC}"
    elif echo "$html" | grep -iq "Drupal"; then
        echo -e "${GREEN}[+] Drupal Detected${NC}"
    else
        echo -e "${RED}[-] CMS not detected (or custom CMS)${NC}"
    fi
}

function website_status_check() {
    check_and_install "curl" "curl" || return
    ask_target
    echo -e "${CYAN}Checking detailed HTTP status for $target...${NC}"
    curl -s -o /dev/null -w "\
Status Code     : %{http_code}\n\
Redirect URL    : %{redirect_url}\n\
Server          : %{server}\n\
Content-Type    : %{content_type}\n\
Total Time      : %{time_total} seconds\n" "https://$target"
}

function reverse_dns() {
    check_and_install "dig" "dnsutils" || return
    read -p "Enter IP address: " ip
    echo -e "${CYAN}Performing reverse DNS lookup for $ip...${NC}"
    dig -x "$ip" +short
}

# Main Loop
while true; do
    show_menu
    read -p "$(echo -e ${CYAN}Choose option: ${NC})" choice
    case $choice in
        1) ask_target; ping -c 4 "$target"; pause_continue ;;
        2) check_and_install "dig" "dnsutils" || continue; ask_target; dig "$target" +short || nslookup "$target"; pause_continue ;;
        3) check_and_install "whois" "whois" || continue; ask_target; whois "$target"; pause_continue ;;
        4) traceroute_scan; pause_continue ;;
        5) port_scan; pause_continue ;;
        6) check_and_install "curl" "curl" || continue; ask_target; curl -I "https://$target"; pause_continue ;;
        7) ssl_info; pause_continue ;;
        8) subdomain_brute; pause_continue ;;
        9) website_status_check; pause_continue ;;
        10) check_and_install "curl" "curl" || continue; ask_target; curl -o /dev/null -s -w "Load Time: %{time_total} sec\n" "https://$target"; pause_continue ;;
        11) mx_check; pause_continue ;;
        12) cdn_detect; pause_continue ;;
        13) cms_detect; pause_continue ;;
        14) reverse_dns; pause_continue ;;
        0) echo -e "${RED}Goodbye from TraezkDev. Stay Ethical!${NC}"; break ;;
        *) echo -e "${RED}[!] Invalid option${NC}" ;;
    esac
    echo ""
done
