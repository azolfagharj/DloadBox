#!/bin/bash
# DloadBox Installer
# DloadBox is a complete download management platform combining aria2c, Lighttpd, ariaNG, RPC integration, and a Telegram bot.
# It offers a user-friendly web interface and remote control, enabling efficient and scalable management of downloads from anywhere.
#region version
# Version info
VERSION_DLOADBOX="alpha-2.0.5"
VERSION_DLOADBOX_CREATE="2024-12-01"
VERSION_DLOADBOX_UPDATE="2025-01-19"
VERSION_FILEBROWSER="2.31.2"
VERSION_ARIANG="1.3.8"
#endregion
init_variables(){
    #region URL
    # ################################################################################## #
    # #                                   URL                                          # #
    # ################################################################################## #
    # DloadBox URL
    URL_DLOADBOX_GITHUB="https://github.com/azolfaghar/dloadbox"
    URL_DLOADBOX_GITHUB_ISSUES="https://github.com/azolfaghar/dloadbox/issues"
    URL_DLOADBOX_LATEST_ZIP="https://github.com/azolfagharj/DloadBox/releases/download/$VERSION_DLOADBOX/dloadbox.zip"
    URL_FILEBROWSER_TARGZ="https://github.com/filebrowser/filebrowser/releases/download/v$VERSION_FILEBROWSER/linux-amd64-filebrowser.tar.gz"
    URL_ARIANG_ZIP="https://github.com/mayswind/AriaNg/releases/download/$VERSION_ARIANG/AriaNg-$VERSION_ARIANG.zip"
    #endregion
    #region hierarchy
    # ################################################################################## #
    # #                               DloadBox Hierarchy                               # #
    # ################################################################################## #
    # Info file
    file_dloadbox_info="/opt/dloadbox/dloadbox-info"
    # Config files
    file_config_aria2="/opt/dloadbox/config/dloadbox-aria2.conf"
    file_config_webserver="/opt/dloadbox/config/dloadbox-lighttpd.conf"
    file_config_telegram_bot="/opt/dloadbox/config/dloadbox-telegram-bot.conf"
    file_config_filebrowser_json="/opt/dloadbox/config/dloadbox-filebrowser.json"
    file_config_filebrowser_db="/opt/dloadbox/config/dloadbox-filebrowser.db"
    # Services files
    file_service_ariarpc="/opt/dloadbox/services/dloadbox-aria2rpc.service"
    file_service_webserver="/opt/dloadbox/services/dloadbox-lighttpd.service"
    file_service_telegram_bot="/opt/dloadbox/services/dloadbox-telegram.service"
    file_service_filebrowser="/opt/dloadbox/services/dloadbox-filebrowser.service"
    # Binaries
    file_bin_aria2c="/usr/bin/aria2c"
    file_bin_lighttpd="/usr/sbin/lighttpd"
    file_bin_telegram_bot="/opt/dloadbox/bin/dloadbox-telegrambot.py"
    file_bin_filebrowser="/opt/dloadbox/bin/dloadbox-filebrowser"
    file_bin_dloadbox_manager="/opt/dloadbox/bin/dloadbox-manager.sh"
    file_bin_dloadbox_installer="/opt/dloadbox/bin/dloadbox-installer.sh"
    # Symbolic links
    symb_config_webserver="/etc/lighttpd/conf-enabled/dloadbox-lighttpd.conf"
    symb_service_ariarpc="/etc/systemd/system/dloadbox-ariarpc.service"
    symb_service_filebrowser="/etc/systemd/system/dloadbox-filebrowser.service"
    symb_service_telegram_bot="/etc/systemd/system/dloadbox-telegram.service"
    symb_bin_filebrowser="/usr/bin/dloadbox-filebrowser"
    # Directories
    dir_dloadbox="/opt/dloadbox"
    dir_bin="/opt/dloadbox/bin"
    dir_config="/opt/dloadbox/config"
    dir_services="/opt/dloadbox/services"
    dir_log="/opt/dloadbox/log"
    dir_www="/opt/dloadbox/www"
    dir_venv="/opt/dloadbox/venv"
    dir_venv_telegrambot="/opt/dloadbox/venv/telegrambot"
    # dloadbox hierarchy array
    hierarchy=(
        "$file_dloadbox_info"
        "$file_config_aria2"
        "$file_config_webserver"
        "$file_config_telegram_bot"
        "$file_config_filebrowser_json"
        "$file_config_filebrowser_db"
        "$file_service_ariarpc"
        "$file_service_webserver"
        "$file_service_telegram_bot"
        "$file_service_filebrowser"
        "$file_bin_aria2c"
        "$file_bin_lighttpd"
        "$file_bin_telegram_bot"
        "$file_bin_filebrowser"
        "$file_bin_dloadbox_manager"
        "$file_bin_dloadbox_installer"
        "$symb_config_webserver"
        "$symb_service_ariarpc"
        "$symb_service_filebrowser"
        "$symb_service_telegram_bot"
        "$symb_bin_filebrowser"
        "$dir_dloadbox"
        "$dir_bin"
        "$dir_config"
        "$dir_services"
        "$dir_log"
        "$dir_www"
        "$dir_venv"
        "$dir_venv_telegrambot"
    )
    #endregion
    #region variables
    # ################################################################################## #
    # #                               DloadBox Variables                               # #
    # ################################################################################## #
    # Secrets variables
    SECRET_ARIA2_RPCTOKEN=""
    SECRET_ARIA2_RPCTOKEN_HASH=""
    SECRET_TELEGRAM_BOT_TOKEN=""
    SECRET_FILEBROWSER_PASSWORD=""
    SECRET_FILEBROWSER_PASSWORD_HASH=""
    # User variables
    USERNAME_FILEBROWSER=""
    USERNAME_TELEGRAM_BOT=""
    USERNAME_TELEGRAM_ALLOWED=""
    # Network variables
    IP_MAIN=""
    PORT_RPC=""
    PORT_WEBSERVER=""
    PORT_FILEBROWSER=""
    # Services variables
    SERVICE_ARIARPC=""
    SERVICE_FILEBROWSER=""
    SERVICE_TELEGRAM_BOT=""
    # check variables
    CHECK_HIERARCHY_ISOK=true
    #endregion
    #region InternalConfig
    # ################################################################################## #
    # #                               DloadBox Internal Config                       # #
    # ################################################################################## #
    # Aria2 config
    INTERNALCONFIG_ARIA2_RPC_SECRET=""
    INTERNALCONFIG_ARIA2_RPC_LISTEN_PORT=""
    # telegram bot config
    INTERNALCONFIG_TELEGRAMBOT_LIMIT_PERMISSION=""
    INTERNALCONFIG_TELEGRAMBOT_ALLOWED_USERNAMES=""
    INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET=""
    INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_URL=""
    INTERNALCONFIG_TELEGRAMBOT_BOT_TOKEN=""
    # Webserver config
    INTERNALCONFIG_WEBSERVER_PORT=""
    # Filebrowser config
    INTERNALCONFIG_FILEBROWSER_PASSWORD=""
    INTERNALCONFIG_FILEBROWSER_PASSWORD_HASH=""
    INTERNALCONFIG_FILEBROWSER_USERNAME=""
    INTERNALCONFIG_FILEBROWSER_PORT=""
    # AriaNG config
    INTERNALCONFIG_ARIANG_URL=""
    #endregion
    #region Log
    # ################################################################################## #
    # #                               DloadBox Log                                     # #
    # ################################################################################## #
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
    #endregion
}
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
check_hierarchy(){
    az_log b "Checking DloadBox Files and Directories..."
    for item in "${hierarchy[@]}"; do
        if [[ ! -e "$item" ]]; then
            az_log br "Not found: $item"
            CHECK_HIERARCHY_ISOK=false
        fi
    done
    if $CHECK_HIERARCHY_ISOK; then
        az_log bg "ALL DloadBox Files and Directories Found"
    else
        az_log br "Some DloadBox Files and Directories are missing"
        return 1
    fi
}
config_detector_ip(){
    az_log b "Detecting IP address..."
    if INTERFACE_MAIN=$(ip route | awk '/default/ {print $5}' | head -n 1); then
        az_log b "Main interface is: $INTERFACE_MAIN"
        if IP_MAIN=$(ip addr show "$INTERFACE_MAIN" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1); then
            az_log b " IP is: $IP_MAIN"
        else
            az_log br "Error: Unable to retrieve the main IP."
            return 1
        fi
    else
        az_log br "Error: Unable to retrieve the main interface."
        return 1
    fi
}
config_detector_aria2(){
    az_log b "Detecting aria2 rpc config..."
    if SECRET_ARIA2_RPCTOKEN=$(grep -i rpc-secret "$file_config_aria2" | awk -F'=' '{print $2}'); then
        az_log b "Aria2 rpc secret extracted successfully."
    else
        az_log br "Error: Unable to retrieve the aria2 rpc secret."
        return 1
    fi
}
info_creator(){
    az_log b "Creating dloadbox-info file..."
    if ! ip_detector; then
        az_log br "Error: Unable to retrieve the main IP."
        az_log br "Can't create dloadbox-info file."
        az_log br "you can open a issue on github: https://github.com/azolfaghar/dloadbox/issues"
        az_log br "Returning to the  menu..."
        return 1
    fi

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
    init_variables
    setup_static_header
    check_hierarchy
    main_menu


}
main