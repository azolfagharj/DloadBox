#!/bin/bash
# DloadBox Configurator
# Use to configure DloadBox service based on dloadbox.conf file.
# DloadBox is a complete download management platform combining aria2c, Lighttpd, ariaNG, RPC integration, and a Telegram bot.
# It offers a user-friendly web interface and remote control, enabling efficient and scalable management of downloads from anywhere.

# Version info
VERSION_DLOADBOX="alpha-2.2.9"
VERSION_DLOADBOX_CREATE="2024-12-01"
VERSION_DLOADBOX_UPDATE="2025-04-17"
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
    URL_CADDY_TARGZ="https://github.com/caddyserver/caddy/releases/download/v$VERSION_CADDY/caddy_${VERSION_CADDY}_linux_amd64.tar.gz"
    #endregion
    #region hierarchy
    # ################################################################################## #
    # #                               DloadBox Hierarchy                               # #
    # ################################################################################## #
    # Info file
    file_dloadbox_info="/opt/dloadbox/dloadbox-info"
    # Config files
    file_config_aria2="/opt/dloadbox/config/dloadbox-aria2.conf"
    file_config_ariang="/opt/dloadbox/config/dloadbox-ariang.conf"
    file_config_webserver="/opt/dloadbox/config/dloadbox-caddy.conf"
    file_config_telegram_bot="/opt/dloadbox/config/dloadbox-telegrambot.conf"
    file_config_filebrowser_json="/opt/dloadbox/config/dloadbox-filebrowser.json"
    file_config_filebrowser_db="/opt/dloadbox/config/dloadbox-filebrowser.db"
    file_config_dloadbox="/opt/dloadbox/config/dloadbox.conf"
    # Services files
    file_service_dloadbox="/opt/dloadbox/services/dloadbox.service"
    file_service_ariarpc="/opt/dloadbox/services/dloadbox-ariarpc.service"
    file_service_webserver="/opt/dloadbox/services/dloadbox-caddy.service"
    file_service_telegram_bot="/opt/dloadbox/services/dloadbox-telegrambot.service"
    file_service_filebrowser="/opt/dloadbox/services/dloadbox-filebrowser.service"
    # Binaries
    file_bin_aria2c="/opt/dloadbox/bin/dloadbox-aria2c"
    file_bin_caddy="/opt/dloadbox/bin/dloadbox-caddy"
    file_bin_telegram_bot="/opt/dloadbox/bin/dloadbox-telegrambot"
    file_bin_filebrowser="/opt/dloadbox/bin/dloadbox-filebrowser"
    file_bin_dloadbox_manager="/opt/dloadbox/bin/dloadbox-manager.sh"
    file_bin_dloadbox_installer="/opt/dloadbox/bin/dloadbox-installer.sh"
    file_bin_dloadbox_configurator="/opt/dloadbox/bin/dloadbox-configurator.sh"
    #file_bin_env_python3="/opt/dloadbox/venv/dloadbox-telegrambot/bin/python3"
    # Symbolic links
    #symb_config_webserver="/etc/lighttpd/conf-enabled/dloadbox-lighttpd.conf"
    symb_service_ariarpc="/etc/systemd/system/dloadbox-ariarpc.service"
    symb_service_filebrowser="/etc/systemd/system/dloadbox-filebrowser.service"
    symb_service_telegram_bot="/etc/systemd/system/dloadbox-telegrambot.service"
    symb_service_webserver="/etc/systemd/system/dloadbox-caddy.service"
    symb_bin_filebrowser="/usr/bin/dloadbox-filebrowser"
    symb_bin_dloadbox="/bin/dloadbox"
    # Directories
    dir_dloadbox="/opt/dloadbox"
    dir_bin="/opt/dloadbox/bin"
    dir_config="/opt/dloadbox/config"
    dir_services="/opt/dloadbox/services"
    dir_log="/opt/dloadbox/log"
    dir_www="/opt/dloadbox/www"
    #dir_venv="/opt/dloadbox/venv"
    #dir_venv_telegrambot="/opt/dloadbox/venv/dloadbox-telegrambot/"
    # dloadbox hierarchy array
    hierarchy=(
        "$file_dloadbox_info"
        "$file_config_aria2"
        "$file_config_ariang"
        "$file_config_webserver"
        "$file_config_telegram_bot"
        "$file_config_filebrowser_json"
        "$file_config_dloadbox"
        "$file_bin_caddy"
        "$file_bin_filebrowser"
    )
    #endregion
    #region variables
    # ################################################################################## #
    # #                               DloadBox Variables                               # #
    # ################################################################################## #
    # IP config
    CONFIG_IP_MAIN=""
    CONFIG_INTERFACE_MAIN=""
    # Aria2 config
    CONFIG_ARIA2_RPC_SECRET=""
    CONFIG_ARIA2_RPC_LISTEN_PORT=""
    # Telegram bot config
    CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=""
    CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES=""
    CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET=""
    CONFIG_TELEGRAMBOT_ARIA2_RPC_URL=""
    CONFIG_TELEGRAMBOT_BOT_TOKEN=""
    CONFIG_TELEGRAMBOT_BOT_USERNAME=""
    # Webserver config
    CONFIG_WEBSERVER_PORT=""
    # Filebrowser config
    CONFIG_FILEBROWSER_PASSWORD=""
    CONFIG_FILEBROWSER_PASSWORD_HASH=""
    CONFIG_FILEBROWSER_USERNAME=""
    CONFIG_FILEBROWSER_PORT=""
    # AriaNG config
    CONFIG_ARIANG_URL=""
    CONFIG_ARIANG_RPC_SECRET_HASH=""
    # Caddy config
    CONFIG_CADDY_PASSWORD=""
    CONFIG_CADDY_PASSWORD_HASH=""
    CONFIG_CADDY_USERNAME=""
    # Services name variables
    CONFIG_SERVICE_NAME_ARIARPC=""
    CONFIG_SERVICE_NAME_FILEBROWSER=""
    CONFIG_SERVICE_NAME_TELEGRAM=""
    # check variables
    CHECK_HIERARCHY_ISOK=true
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
    local count=0
    local count_success=0
    local count_failed=0
    CHECK_HIERARCHY_ISOK=true
    az_log b "Checking DloadBox Files and Directories..."
    for item in "${hierarchy[@]}"; do
        ((count++))
        if [[ ! -e "$item" ]]; then
            az_log br "❌ Not found: $item"
            ((count_failed++))
        else
            az_log l "Found: $item"
            ((count_success++))
        fi
    done
    if [[ "$count_failed" == "0" ]]; then
        az_log l "✅ ALL DloadBox Files and Directories Found"
        return 0
    else
        az_log br "❌ Error: $count_failed of $count DloadBox Files and Directories are missing"
        CHECK_HIERARCHY_ISOK=false
        exit 1
    fi
}
main(){
    init_variables
    check_hierarchy
}
main