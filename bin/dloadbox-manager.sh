#!/bin/bash
# DloadBox Installer
# DloadBox is a complete download management platform combining aria2c, Lighttpd, ariaNG, RPC integration, and a Telegram bot.
# It offers a user-friendly web interface and remote control, enabling efficient and scalable management of downloads from anywhere.
# Version: 1.4.1
# Since:    2024-10-01
# Updated : 2024-12-27

VERSION_NUMBER="alpha-2.0.2"
VERSION_CREATE="2024-12-01"
VERSION_UPDATE="2025-01-16"
# Log file
LOG_FILE="/opt/dloadbox/log/dloadbox-manager.log"
# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
# shellcheck disable=SC2034
ORANGE='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
# date format
DATE_FORMAT='+%Y-%m-%d %H:%M:%S'
display_logo() {
    echo ""
    echo -e "                ${BLUE}██████╗ ${GREEN}██╗      ██████╗  █████╗ ██████╗ ${CYAN}██████╗  ██████╗ ██╗  ██╗${NC}"
    echo -e "                ${BLUE}██╔══██╗${GREEN}██║     ██╔═══██╗██╔══██╗██╔══██╗${CYAN}██╔══██╗██╔═══██╗╚██╗██╔╝${NC}"
    echo -e "                ${BLUE}██║  ██║${GREEN}██║     ██║   ██║███████║██║  ██║${CYAN}██████╔╝██║   ██║ ╚███╔╝${NC}"
    echo -e "                ${BLUE}██║  ██║${GREEN}██║     ██║   ██║██╔══██║██║  ██║${CYAN}██╔══██╗██║   ██║ ██╔██╗${NC}"
    echo -e "                ${BLUE}██████╔╝${GREEN}███████╗╚██████╔╝██║  ██║██████╔╝${CYAN}██████╔╝╚██████╔╝██╔╝ ██╗${NC}"
    echo -e "                ${BLUE}╚═════╝ ${GREEN}╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ${CYAN}╚═════╝  ╚═════╝ ╚═╝  ╚═╝${NC}"
    echo -e "                                ${YELLOW}Download Management Platform${NC}"
    echo -e "                                                      ${CYAN}by ${YELLOW}${BOLD}A.ZOLFAGHAR${NC}"
    echo ""
    echo -e "${RED}╭─────────────╮${NC}"
    echo -e "${RED}│   Manager   │${NC}"
    echo -e "${RED}╰─────────────╯${NC}"
    echo ""
}
setup_static_header() {
    clear
    echo -e "\033[H"
    display_logo
    echo -e "\033[15;r"
    echo -e "\033[15;1H"
}
az_log() {
    local mode="${1:-b}"
    local message="$2"

    # Check if message is provided
    if [[ -z "$message" ]]; then
        echo "No message provided."
        return
    fi

    local current_date
    current_date=$(date "$DATE_FORMAT")

    case "$mode" in
        b)
            echo "$message"
            echo "$current_date - $message" >> "$LOG_FILE"
            ;;
        bg)
            echo -e "${GREEN}${BOLD}$message${NC}"
            echo "$current_date - $message" >> "$LOG_FILE"
            ;;
        br)
            echo -e "${RED}${BOLD}$message${NC}"
            echo "$current_date - $message" >> "$LOG_FILE"
            ;;
        l)
            echo "$current_date - $message" >> "$LOG_FILE"
            ;;
        s)
            echo "$message"
            ;;
        sg)
            echo -e "${GREEN}${BOLD}$message${NC}"
            ;;
        sr)
            echo -e "${RED}${BOLD}$message${NC}"
            ;;
        *)
            echo "$message"
            echo "$current_date - $message" >> "$LOG_FILE"
            ;;
    esac
}
main_menu() {
    clear
    setup_static_header
    echo -e "\n  ${BOLD}${CYAN}MAIN MENU${NC}"
    echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "  1) ${GREEN}View DloadBox Access information${NC}"
    echo -e "  2) ${GREEN}Manage DloadBox services${NC}"
    echo -e "  3) ${GREEN}Change Configuration & Settings${NC}"
    echo -e "  4) ${RED}Uninstall Or Reinstall Dloadbox${NC}"
    echo -e "  e) ${YELLOW}Exit${NC}"
    echo -en "\nEnter your choice: "
    read -r choice
    case $choice in
        1)
            info_menu
            ;;
        2)
            services_menu
            ;;
        3)
            settings_menu
            ;;
        4)
            uninstall_reinstall_menu
            ;;
        e)
            echo "Exiting..."
            clear
            exit 0
            ;;
        *)
            echo "Invalid choice, try again."
            sleep 1
            main_menu
            ;;
    esac
}
services_menu() {
    clear
    setup_static_header
    echo -e "\n  ${BOLD}${CYAN}MAIN MENU > SERVICES${NC}"
    echo -e "  ${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "  1) ${GREEN}Check DloadBox services status${NC}"
    echo -e "  2) ${GREEN}Restart DloadBox services${NC}"
    echo -e "  3) ${GREEN}Stop DloadBox services${NC}"
    echo -e "  4) ${GREEN}Start DloadBox services${NC}"
    echo -e "  0) ${YELLOW}Back to Main Menu${NC}"
    echo -e "  e) ${YELLOW}Exit${NC}"
    echo -en "\nEnter your choice: "
    read -r choice
    case $choice in
        1)
            check_services_status
            ;;
        2)
            restart_services_menu
            ;;
        3)
            stop_services_menu
            ;;
        4)
            start_services_menu
            ;;
        0)
            main_menu
            ;;
        e)
            echo "Exiting..."
            clear
            exit 0
            ;;
        *)
            echo "Invalid choice, try again."
            sleep 1
            services_menu
            ;;
    esac
}
main() {
    setup_static_header
    main_menu


}
main