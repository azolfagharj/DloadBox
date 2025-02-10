#!/bin/bash
# DloadBox Installer
# DloadBox is a complete download management platform combining aria2c, Lighttpd, ariaNG, RPC integration, and a Telegram bot.
# It offers a user-friendly web interface and remote control, enabling efficient and scalable management of downloads from anywhere.
#region version
# Version info
VERSION_DLOADBOX="alpha-2.2.3"
VERSION_DLOADBOX_CREATE="2024-12-01"
VERSION_DLOADBOX_UPDATE="2025-02-10"
VERSION_FILEBROWSER="2.31.2"
VERSION_ARIANG="1.3.8"
VERSION_CADDY="2.9.1"
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
    file_config_webserver="/opt/dloadbox/config/dloadbox-caddy.conf"
    file_config_telegram_bot="/opt/dloadbox/config/dloadbox-telegrambot.conf"
    file_config_filebrowser_json="/opt/dloadbox/config/dloadbox-filebrowser.json"
    file_config_filebrowser_db="/opt/dloadbox/config/dloadbox-filebrowser.db"
    # Services files
    file_service_ariarpc="/opt/dloadbox/services/dloadbox-ariarpc.service"
    file_service_webserver="/opt/dloadbox/services/dloadbox-caddy.service"
    file_service_telegram_bot="/opt/dloadbox/services/dloadbox-telegrambot.service"
    file_service_filebrowser="/opt/dloadbox/services/dloadbox-filebrowser.service"
    # Binaries
    file_bin_aria2c="/usr/bin/aria2c"
    file_bin_caddy="/opt/dloadbox/bin/dloadbox-caddy"
    file_bin_telegram_bot="/opt/dloadbox/bin/dloadbox-telegrambot"
    file_bin_filebrowser="/opt/dloadbox/bin/dloadbox-filebrowser"
    file_bin_dloadbox_manager="/opt/dloadbox/bin/dloadbox-manager.sh"
    file_bin_dloadbox_installer="/opt/dloadbox/bin/dloadbox-installer.sh"
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
        "$file_config_webserver"
        "$file_config_telegram_bot"
        "$file_config_filebrowser_json"
        "$file_config_filebrowser_db"
        "$file_service_ariarpc"
        "$file_service_webserver"
        "$file_service_telegram_bot"
        "$file_service_filebrowser"
        "$file_bin_aria2c"
        "$file_bin_caddy"
        "$file_bin_telegram_bot"
        "$file_bin_filebrowser"
        "$file_bin_dloadbox_manager"
        "$file_bin_dloadbox_installer"
        #"$file_bin_env_python3"
        #"$symb_config_webserver"
        "$symb_service_ariarpc"
        "$symb_service_filebrowser"
        "$symb_service_telegram_bot"
        "$symb_service_webserver"
        "$symb_bin_filebrowser"
        "$symb_bin_dloadbox"
        "$dir_dloadbox"
        "$dir_bin"
        "$dir_config"
        "$dir_services"
        "$dir_log"
        "$dir_www"
        #"$dir_venv"
        #"$dir_venv_telegrambot"
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
    CHECK_INFOCONFIG_ISOK=true
    #endregion
    #region InternalConfig
    # ################################################################################## #
    # #                               DloadBox Internal Config                       # #
    # ################################################################################## #
    # IP config
    INTERNALCONFIG_IP_MAIN=""
    INTERNALCONFIG_INTERFACE_MAIN=""
    # Aria2 config
    INTERNALCONFIG_ARIA2_RPC_SECRET=""
    INTERNALCONFIG_ARIA2_RPC_LISTEN_PORT=""
    # telegram bot config
    INTERNALCONFIG_TELEGRAMBOT_LIMIT_PERMISSION=""
    INTERNALCONFIG_TELEGRAMBOT_ALLOWED_USERNAMES=""
    INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET=""
    INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_URL=""
    INTERNALCONFIG_TELEGRAMBOT_BOT_TOKEN=""
    INTERNALCONFIG_TELEGRAMBOT_BOT_USERNAME=""
    # Webserver config
    INTERNALCONFIG_WEBSERVER_PORT=""
    # Filebrowser config
    INTERNALCONFIG_FILEBROWSER_PASSWORD=""
    INTERNALCONFIG_FILEBROWSER_PASSWORD_HASH=""
    INTERNALCONFIG_FILEBROWSER_USERNAME=""
    INTERNALCONFIG_FILEBROWSER_PORT=""
    # AriaNG config
    INTERNALCONFIG_ARIANG_URL=""
    INTERNALCONFIG_ARIANG_RPC_SECRET_HASH=""
    # Services name variables
    INTERNALCONFIG_SERVICE_NAME_ARIARPC=""
    INTERNALCONFIG_SERVICE_NAME_FILEBROWSER=""
    INTERNALCONFIG_SERVICE_NAME_TELEGRAM=""
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
service_manager() {
    local action=""
    local services=()
    local exit_code=0
    local quiet=false

    # Initial daemon-reload
    az_log b "🔄 Reloading systemd daemon..."
    if systemctl daemon-reload &>/dev/null; then
        az_log bg "✅ Systemd daemon reloaded successfully"
    else
        az_log br "❌ Failed to reload systemd daemon"
        return 1
    fi
    az_log b "---------------------------------"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --start|--stop|--restart|--enable|--disable|--remove)
                action="$1"
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            *)
                services+=("$1")
                shift
                ;;
        esac
    done

    # Validate inputs
    if [ -z "$action" ]; then
        [[ $quiet == false ]] && az_log br "❌ No action specified! Use --start, --stop, --restart, --enable, --disable, or --remove"
        return 1
    fi

    if [ ${#services[@]} -eq 0 ]; then
        [[ $quiet == false ]] && az_log br "❌ No services specified!"
        return 1
    fi

    # Process each service
    for service in "${services[@]}"; do
        case "$action" in
            --start)
                [[ $quiet == false ]] && az_log b "🔄 Checking service: $service"
                if systemctl list-unit-files | grep -q "$service"; then
                    if systemctl is-active --quiet "$service"; then
                        [[ $quiet == false ]] && az_log bg "✅ Service $service is already running"
                    else
                        [[ $quiet == false ]] && az_log b "🔄 Starting service: $service"
                        if systemctl start "$service" &>/dev/null; then
                            sleep 1
                            if systemctl is-active --quiet "$service"; then
                                [[ $quiet == false ]] && az_log bg "✅ Service $service started successfully"
                            else
                                [[ $quiet == false ]] && az_log br "❌ Service $service failed to start (not active after start)"
                                exit_code=1
                            fi
                        else
                            [[ $quiet == false ]] && az_log br "❌ Failed to start service: $service"
                            exit_code=1
                        fi
                    fi
                else
                    [[ $quiet == false ]] && az_log br "❌ Service $service does not exist"
                    exit_code=1
                fi
                ;;

            --stop)
                [[ $quiet == false ]] && az_log b "🔄 Checking service: $service"
                if systemctl list-unit-files | grep -q "$service"; then
                    if ! systemctl is-active --quiet "$service"; then
                        [[ $quiet == false ]] && az_log bg "✅ Service $service is already stopped"
                    else
                        [[ $quiet == false ]] && az_log b "🔄 Stopping service: $service"
                        if systemctl stop "$service" &>/dev/null; then
                            sleep 1
                            if ! systemctl is-active --quiet "$service"; then
                                [[ $quiet == false ]] && az_log bg "✅ Service $service stopped successfully"
                            else
                                [[ $quiet == false ]] && az_log br "❌ Service $service failed to stop (still active after stop)"
                                exit_code=1
                            fi
                        else
                            [[ $quiet == false ]] && az_log br "❌ Failed to stop service: $service"
                            exit_code=1
                        fi
                    fi
                else
                    [[ $quiet == false ]] && az_log br "❌ Service $service does not exist"
                    exit_code=1
                fi
                ;;

            --restart)
                [[ $quiet == false ]] && az_log b "🔄 Checking service: $service"
                if systemctl list-unit-files | grep -q "$service"; then
                    [[ $quiet == false ]] && az_log b "🔄 Restarting service: $service"
                    if systemctl restart "$service" &>/dev/null; then
                        sleep 1
                        if systemctl is-active --quiet "$service"; then
                            [[ $quiet == false ]] && az_log bg "✅ Service $service restarted successfully"
                        else
                            [[ $quiet == false ]] && az_log br "❌ Service $service failed to restart (not active after restart)"
                            exit_code=1
                        fi
                    else
                        [[ $quiet == false ]] && az_log br "❌ Failed to restart service: $service"
                        exit_code=1
                    fi
                else
                    [[ $quiet == false ]] && az_log br "❌ Service $service does not exist"
                    exit_code=1
                fi
                ;;

            --enable)
                [[ $quiet == false ]] && az_log b "🔄 Checking service: $service"
                if systemctl list-unit-files | grep -q "$service"; then
                    if systemctl is-enabled --quiet "$service"; then
                        [[ $quiet == false ]] && az_log bg "✅ Service $service is already enabled"
                    else
                        [[ $quiet == false ]] && az_log b "🔄 Enabling service: $service"
                        if systemctl enable "$service" &>/dev/null; then
                            if systemctl is-enabled --quiet "$service"; then
                                [[ $quiet == false ]] && az_log bg "✅ Service $service enabled successfully"
                            else
                                [[ $quiet == false ]] && az_log br "❌ Service $service failed to enable (not enabled after enable command)"
                                exit_code=1
                            fi
                        else
                            [[ $quiet == false ]] && az_log br "❌ Failed to enable service: $service"
                            exit_code=1
                        fi
                    fi
                else
                    [[ $quiet == false ]] && az_log br "❌ Service $service does not exist"
                    exit_code=1
                fi
                ;;

            --disable)
                [[ $quiet == false ]] && az_log b "🔄 Checking service: $service"
                if systemctl list-unit-files | grep -q "$service"; then
                    if ! systemctl is-enabled --quiet "$service"; then
                        [[ $quiet == false ]] && az_log bg "✅ Service $service is already disabled"
                    else
                        [[ $quiet == false ]] && az_log b "🔄 Disabling service: $service"
                        if systemctl disable "$service" &>/dev/null; then
                            if ! systemctl is-enabled --quiet "$service"; then
                                [[ $quiet == false ]] && az_log bg "✅ Service $service disabled successfully"
                            else
                                [[ $quiet == false ]] && az_log br "❌ Service $service failed to disable (still enabled after disable command)"
                                exit_code=1
                            fi
                        else
                            [[ $quiet == false ]] && az_log br "❌ Failed to disable service: $service"
                            exit_code=1
                        fi
                    fi
                else
                    [[ $quiet == false ]] && az_log br "❌ Service $service does not exist"
                    exit_code=1
                fi
                ;;

            --remove)
                [[ $quiet == false ]] && az_log b "🔄 Checking service: $service"
                if systemctl list-unit-files | grep -q "$service"; then
                    if systemctl is-active --quiet "$service"; then
                        [[ $quiet == false ]] && az_log b "🔄 Stopping service: $service"
                        if ! systemctl stop "$service" &>/dev/null; then
                            [[ $quiet == false ]] && az_log br "❌ Failed to stop service: $service"
                            exit_code=1
                            continue
                        fi
                        sleep 1
                        if systemctl is-active --quiet "$service"; then
                            [[ $quiet == false ]] && az_log br "❌ Service $service failed to stop (still active)"
                            exit_code=1
                            continue
                        fi
                    fi

                    if systemctl is-enabled --quiet "$service"; then
                        [[ $quiet == false ]] && az_log b "🔄 Disabling service: $service"
                        if ! systemctl disable "$service" &>/dev/null; then
                            [[ $quiet == false ]] && az_log br "❌ Failed to disable service: $service"
                            exit_code=1
                            continue
                        fi
                    fi

                    # First check if service file exists in /etc/systemd/system/
                    if [ -f "/etc/systemd/system/${service}.service" ]; then
                        local service_path
                        service_path=$(systemctl show -p FragmentPath "$service" | cut -d'=' -f2)
                        if [ -f "$service_path" ]; then
                            [[ $quiet == false ]] && az_log b "🔄 Removing service file: $service"
                            if rm "$service_path" &>/dev/null; then
                                systemctl daemon-reload &>/dev/null
                                [[ $quiet == false ]] && az_log bg "✅ Service $service removed successfully"
                            else
                                [[ $quiet == false ]] && az_log br "❌ Failed to remove service file: $service"
                                exit_code=1
                            fi
                        else
                            [[ $quiet == false ]] && az_log br "❌ Service file not found: $service"
                            exit_code=1
                        fi
                    fi
                else
                    [[ $quiet == false ]] && az_log br "❌ Service $service does not exist"
                    exit_code=1
                fi
                ;;
        esac
    done

    # Final daemon-reload
    [[ $quiet == false ]] && az_log b "---------------------------------"
    [[ $quiet == false ]] && az_log b "🔄 Reloading systemd daemon..."
    if systemctl daemon-reload &>/dev/null; then
        [[ $quiet == false ]] && az_log bg "✅ Systemd daemon reloaded successfully"
    else
        [[ $quiet == false ]] && az_log br "❌ Failed to reload systemd daemon"
        exit_code=1
    fi

    return $exit_code
}
check_hierarchy(){
    local count=0
    local count_success=0
    local count_failed=0
    CHECK_HIERARCHY_ISOK=true
    sleep 1
    az_log b "Checking DloadBox Files and Directories..."
    sleep 1
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
        az_log bg "✅ ALL DloadBox Files and Directories Found"
        return 0
    else
        az_log br "❌ Error: $count_failed of $count DloadBox Files and Directories are missing"
        CHECK_HIERARCHY_ISOK=false
        return 1
    fi
}
config_detector_info(){
    az_log b "Detecting dloadbox-info Config..."
    CHECK_INFOCONFIG_ISOK=true
    local count=0
    local count_success=0
    local count_failed=0
    if [ -f "$file_dloadbox_info" ]; then
        # Create arrays for the keys and corresponding variable names
        local config_keys=("INTERNALCONFIG_IP_MAIN" "INTERNALCONFIG_INTERFACE_MAIN" "INTERNALCONFIG_ARIA2_RPC_SECRET" "INTERNALCONFIG_ARIA2_RPC_LISTEN_PORT" "INTERNALCONFIG_TELEGRAMBOT_LIMIT_PERMISSION" "INTERNALCONFIG_TELEGRAMBOT_ALLOWED_USERNAMES" "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET" "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_URL" "INTERNALCONFIG_TELEGRAMBOT_BOT_TOKEN" "INTERNALCONFIG_TELEGRAMBOT_BOT_USERNAME" "INTERNALCONFIG_WEBSERVER_PORT"  "INTERNALCONFIG_FILEBROWSER_PASSWORD_HASH" "INTERNALCONFIG_FILEBROWSER_USERNAME" "INTERNALCONFIG_FILEBROWSER_PORT" "INTERNALCONFIG_ARIANG_RPC_SECRET_HASH" "INTERNALCONFIG_ARIANG_URL")
        local config_vars=("INTERNALCONFIG_IP_MAIN" "INTERNALCONFIG_INTERFACE_MAIN" "INTERNALCONFIG_ARIA2_RPC_SECRET" "INTERNALCONFIG_ARIA2_RPC_LISTEN_PORT" "INTERNALCONFIG_TELEGRAMBOT_LIMIT_PERMISSION" "INTERNALCONFIG_TELEGRAMBOT_ALLOWED_USERNAMES" "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET" "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_URL" "INTERNALCONFIG_TELEGRAMBOT_BOT_TOKEN" "INTERNALCONFIG_TELEGRAMBOT_BOT_USERNAME" "INTERNALCONFIG_WEBSERVER_PORT"  "INTERNALCONFIG_FILEBROWSER_PASSWORD_HASH" "INTERNALCONFIG_FILEBROWSER_USERNAME" "INTERNALCONFIG_FILEBROWSER_PORT" "INTERNALCONFIG_ARIANG_RPC_SECRET_HASH" "INTERNALCONFIG_ARIANG_URL")

        # Clear all variables before starting
        az_log b "Clearing all previous values before starting..."
        for var in "${config_vars[@]}"; do
            eval "$var=''"
        done

        # Loop through the keys and extract values
        for i in "${!config_keys[@]}"; do
            ((count++))
            key="${config_keys[$i]}"
            var="${config_vars[$i]}"
            value=$(grep -iw "$key" "$file_dloadbox_info" | awk -F'=' '{print $2}' 2>/dev/null)
            if [ -z "$value" ]; then
                az_log br "Error: Unable to retrieve $key from dloadbox-info file."
                ((count_failed++))
            else
                eval "$var=\"$value\""
                az_log l "SUCCESS: $key extracted successfully: $value"
                ((count_success++))
            fi
        done
    else
        az_log br "Error: Can't Detect DloadBox Configs: File: $file_dloadbox_info not found."
        CHECK_INFOCONFIG_ISOK=false
    fi
    if [[ "$count_failed" == "0" ]]; then
        az_log bg "All $count  DloadBox  Configs successfully detected from dloadbox-info file."
        CHECK_INFOCONFIG_ISOK=true
        return 0
    else
        az_log br "Error: $count_failed Item out of $count DloadBox configurations could not be Extracted."
        CHECK_INFOCONFIG_ISOK=false
        return 1
    fi
}
config_detector(){
    CHECK_CONFIG_ISOK=true
    az_log b "Detecting all DloadBox Configurations"
    check_hierarchy
    if [[ "$CHECK_HIERARCHY_ISOK" == "false" ]]; then
        az_log br "Error: Some DloadBox Files and Directories are missing, can't detect all DloadBox Configs"
        CHECK_CONFIG_ISOK=false
        return 1
    fi
    local config_vars=("CONFIG_IP_MAIN" "CONFIG_INTERFACE_MAIN" "CONFIG_ARIA2_RPC_SECRET" "CONFIG_ARIA2_RPC_LISTEN_PORT" "CONFIG_TELEGRAMBOT_LIMIT_PERMISSION" "CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES" "CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET" "CONFIG_TELEGRAMBOT_ARIA2_RPC_URL" "CONFIG_TELEGRAMBOT_BOT_TOKEN" "CONFIG_TELEGRAMBOT_BOT_USERNAME" "CONFIG_WEBSERVER_PORT" "CONFIG_FILEBROWSER_PASSWORD_HASH" "CONFIG_FILEBROWSER_USERNAME" "CONFIG_FILEBROWSER_PORT" "CONFIG_ARIANG_RPC_SECRET_HASH" "CONFIG_ARIANG_URL")
    local total_configs=${#config_vars[@]}
    local total_failed=0
    local total_success=0
    az_log b "Total number of configurations: $total_configs"
    az_log b "Clearing all previous values before starting..."
    for var in "${config_vars[@]}"; do
        eval "$var=''"
    done
    az_log l "Detecting Main Network Interface and IP Address..."
    CONFIG_INTERFACE_MAIN=$(ip route | awk '/default/ {print $5}' | head -n 1)
    CONFIG_IP_MAIN=$(ip addr show "$CONFIG_INTERFACE_MAIN" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)
    # Aria2 config
    az_log l "Detecting ARIA2 RPC  Configuration..."
    CONFIG_ARIA2_RPC_SECRET=$(grep -i rpc-secret "$file_config_aria2" | awk -F'=' '{print $2}')
    CONFIG_ARIA2_RPC_SECRET_HASH=$(echo -n "$CONFIG_ARIA2_RPC_SECRET" | base64 | tr '+/' '-_' | sed 's/=//g')
    CONFIG_ARIA2_RPC_LISTEN_PORT=$(grep -i rpc-listen-port "$file_config_aria2" | awk -F'=' '{print $2}')
    # Telegram bot config
    az_log l "Detecting telegram bot config..."
    CONFIG_TELEGRAMBOT_BOT_TOKEN=$(grep -i BOT_TOKEN "$file_config_telegram_bot" | awk -F'=' '{print $2}')
    CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=$(grep -i LIMIT_PERMISSION "$file_config_telegram_bot" | awk -F'=' '{print $2}')
    CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES=$(grep -i ALLOWED_USERNAMES "$file_config_telegram_bot" | awk -F'=' '{print $2}')
    CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET="token:${CONFIG_ARIA2_RPC_SECRET}"
    CONFIG_TELEGRAMBOT_ARIA2_RPC_URL="http://${CONFIG_IP_MAIN}:${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc"
    CONFIG_TELEGRAMBOT_BOT_USERNAME=$(curl -s "https://api.telegram.org/bot$CONFIG_TELEGRAMBOT_BOT_TOKEN/getMe" | grep -o '"username":"[^"]*"' | sed -E 's/"username":"(.*)"/\1/')
    # Webserver config
    az_log l "Detecting Webserver Configuration..."
    CONFIG_WEBSERVER_PORT=$(grep -i server.port "$file_config_webserver" | awk -F'=' '{print substr($2, 2)}')
    # Filebrowser config
    az_log l "Detecting Filebrowser Configuration..."
    CONFIG_FILEBROWSER_PASSWORD_HASH=$(grep -i password "$file_config_filebrowser_json" |  awk -F'"' '{print $4}')
    CONFIG_FILEBROWSER_USERNAME=$(grep -i username "$file_config_filebrowser_json" | awk -F'"' '{print $4}')
    CONFIG_FILEBROWSER_PORT=$(grep -Eo '"port": [0-9]+' "$file_config_filebrowser_json" | awk '{print $2}')
    # ariang config
    az_log l "Detecting Ariang Configuration..."
    CONFIG_ARIANG_RPC_SECRET_HASH=$(echo -n "$CONFIG_ARIA2_RPC_SECRET" | base64 | tr '+/' '-_' | sed 's/=//g')
    CONFIG_ARIANG_URL="http://${CONFIG_IP_MAIN}:${CONFIG_WEBSERVER_PORT}/#!/settings/rpc/set/http/${CONFIG_IP_MAIN}/${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc/${CONFIG_ARIANG_RPC_SECRET_HASH}"
    # check if all configs are set
    for var in "${config_vars[@]}"; do
        value="${!var}"
        if [[ -n $value ]]; then
            az_log l "SUCCESS: $var is set to $value"
            ((total_success++))
        else
            az_log br "ERROR: $var is not set"
            ((total_failed++))
            CHECK_CONFIG_ISOK=false
        fi
    done
    if $CHECK_CONFIG_ISOK; then
        az_log bg "All DloadBox $total_configs Configurations Successfully Detected"
        return 0
    else
        az_log br "Error: $total_failed Config out of $total_configs DloadBox Configurations Not Detected"
        return 1
    fi
}
config_changer(){
    az_log b "Changing DloadBox Configurations"
    CHANGE_CONFIG_ISOK=true
    check_hierarchy
    if [[ "$CHECK_HIERARCHY_ISOK" == "false" ]]; then
        az_log br "Error: Some DloadBox Files and Directories are missing, can't change all DloadBox Configs"
        CHECK_CONFIG_ISOK=false
        return 1
    fi
    local config_vars=("CONFIG_IP_MAIN" "CONFIG_INTERFACE_MAIN" "CONFIG_ARIA2_RPC_SECRET" "CONFIG_ARIA2_RPC_LISTEN_PORT" "CONFIG_TELEGRAMBOT_LIMIT_PERMISSION" "CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES" "CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET" "CONFIG_TELEGRAMBOT_ARIA2_RPC_URL" "CONFIG_TELEGRAMBOT_BOT_TOKEN" "CONFIG_TELEGRAMBOT_BOT_USERNAME" "CONFIG_WEBSERVER_PORT"  "CONFIG_FILEBROWSER_PASSWORD_HASH" "CONFIG_FILEBROWSER_USERNAME" "CONFIG_FILEBROWSER_PORT" "CONFIG_ARIANG_RPC_SECRET_HASH" "CONFIG_ARIANG_URL")
    az_log b "Creating some dynamic values..."
    CONFIG_INTERFACE_MAIN=$(ip route | awk '/default/ {print $5}' | head -n 1)
    CONFIG_IP_MAIN=$(ip addr show "$CONFIG_INTERFACE_MAIN" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1)
    # TELEGRAMBOT BOT USERNAME
    CONFIG_TELEGRAMBOT_BOT_USERNAME=$(curl -s "https://api.telegram.org/bot$CONFIG_TELEGRAMBOT_BOT_TOKEN/getMe" | grep -o '"username":"[^"]*"' | sed -E 's/"username":"(.*)"/\1/')
    CONFIG_TELEGRAMBOT_ARIA2_RPC_URL="http://${CONFIG_IP_MAIN}:${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc"
    CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET="token:${CONFIG_ARIA2_RPC_SECRET}"
    CONFIG_ARIANG_RPC_SECRET_HASH=$(echo -n "$CONFIG_ARIA2_RPC_SECRET" | base64 | tr '+/' '-_' | sed 's/=//g')
    CONFIG_ARIANG_URL="http://${CONFIG_IP_MAIN}:${CONFIG_WEBSERVER_PORT}/#!/settings/rpc/set/http/${CONFIG_IP_MAIN}/${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc/${CONFIG_ARIANG_RPC_SECRET_HASH}"
    az_log bg "Done"
    # Check if all config variables are set
    az_log b "Checking if all config variables are set..."
    for var in "${config_vars[@]}"; do
        value="${!var}"
        if [[ -n $value ]]; then
            az_log l "SUCCESS: $var is set to $value"
        else
            az_log br "ERROR: $var is not set"
            az_log br "So DloadBox Config Changer Can't Change Configurations"
            CHANGE_CONFIG_ISOK=false
            return 1
        fi
    done
    az_log bg "SUCCESS: All config variables are set, Going to the next steps..."
    # ARIA2 RPC Listen Port
    if sed -i "/rpc-listen-port/c\\rpc-listen-port=${CONFIG_ARIA2_RPC_LISTEN_PORT}" "$file_config_aria2"; then
        az_log l "ARIA2 RPC Listen Port changed to ${CONFIG_ARIA2_RPC_LISTEN_PORT}"
    else
        az_log br "Error: Failed to change ARIA2 RPC Listen Port"
        CHANGE_CONFIG_ISOK=false
    fi
    # ARIA2 RPC Secret
    if sed -i "/rpc-secret/c\\rpc-secret=${CONFIG_ARIA2_RPC_SECRET}" "$file_config_aria2"; then
        az_log l "ARIA2 RPC Secret changed to ${CONFIG_ARIA2_RPC_SECRET}"
    else
        az_log br "Error: Failed to change ARIA2 RPC Secret"
        CHANGE_CONFIG_ISOK=false
    fi
    # TELEGRAMBOT LIMIT PERMISSION
    if [[ "$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION" == "true" ]]; then
        sed -i '/LIMIT_PERMISSION/c\LIMIT_PERMISSION=true' "$file_config_telegram_bot" &>/dev/null
        sed -i "s|^ALLOWED_USERNAMES=.*|ALLOWED_USERNAMES=${CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES}|" "$file_config_telegram_bot" &>/dev/null
        az_log l "Telegram Bot Limit Permission set to true"
        az_log l "Allowed Usernames: ${CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES}"
    elif [[ "$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION" == "false" ]]; then
        sed -i '/LIMIT_PERMISSION/c\LIMIT_PERMISSION=false' "$file_config_telegram_bot" &>/dev/nulll
        sed -i "s|^ALLOWED_USERNAMES=.*|ALLOWED_USERNAMES=ALL|" "$file_config_telegram_bot" &>/dev/null
    else
        az_log br "Error: Failed to set Telegram Bot Limit Permission"
        CHANGE_CONFIG_ISOK=false
    fi
    # TELEGRAMBOT BOT TOKEN
    if sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=${CONFIG_TELEGRAMBOT_BOT_TOKEN}|" "$file_config_telegram_bot" &>/dev/null; then
        az_log l "Telegram Bot Token set successfully"
    else
        az_log br "Error: Failed to set Telegram Bot Token"
        CHANGE_CONFIG_ISOK=false
    fi
    # TELEGRAMBOT ARIA2 RPC SECRET
    if sed -i "s|^ARIA2_RPC_SECRET=.*|ARIA2_RPC_SECRET=${CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET}|" "$file_config_telegram_bot" &>/dev/null; then
        az_log l "Telegram Bot ARIA2 RPC Secret set successfully"
    else
        az_log br "Error: Failed to set Telegram Bot ARIA2 RPC Secret"
        CHANGE_CONFIG_ISOK=false
    fi
    # TELEGRAMBOT ARIA2 RPC URL
    if sed -i "s|^ARIA2_RPC_URL=.*|ARIA2_RPC_URL=${CONFIG_TELEGRAMBOT_ARIA2_RPC_URL}|" "$file_config_telegram_bot" &>/dev/null; then
        az_log l "Telegram Bot ARIA2 RPC URL set successfully"
    else
        az_log br "Error: Failed to set Telegram Bot ARIA2 RPC URL"
        CHANGE_CONFIG_ISOK=false
    fi
    # WEBSERVER PORT
    if sed -i -E "s/^(server\.port[[:space:]]*=[[:space:]]*)[0-9]+/\1$CONFIG_WEBSERVER_PORT/" "$file_config_webserver"; then
        az_log l "Webserver Port changed to ${CONFIG_WEBSERVER_PORT}"
    else
        az_log br "Error: Failed to change Webserver Port"
        CHANGE_CONFIG_ISOK=false
    fi
    # FILEBROWSER PORT
    if sed -i -E "s/\"port\": [0-9]+/\"port\": $CONFIG_FILEBROWSER_PORT/" "$file_config_filebrowser_json"; then
        az_log l "Filebrowser Port changed to ${CONFIG_FILEBROWSER_PORT}"
    else
        az_log br "Error: Failed to change Filebrowser Port"
        CHANGE_CONFIG_ISOK=false
    fi
    # FILEBROWSER PASSWORD
    if sed -i "/\"password\"/c\    \"password\": \"$CONFIG_FILEBROWSER_PASSWORD_HASH\"" "$file_config_filebrowser_json" &>/dev/null; then
        az_log l "Filebrowser Password hash set successfully"
    else
        az_log br "Error: Failed to set Filebrowser Password hash"
        CHANGE_CONFIG_ISOK=false
    fi
    # FILEBROWSER USERNAME
    if sed -i "/\"username\"/c\    \"username\": \"$CONFIG_FILEBROWSER_USERNAME\"" "$file_config_filebrowser_json" &>/dev/null; then
        az_log l "Filebrowser Username set successfully"
    else
        az_log br "Error: Failed to set Filebrowser Username"
        CHANGE_CONFIG_ISOK=false
    fi
    if [[ "$CHANGE_CONFIG_ISOK" == "true" ]]; then
        az_log bg "All DloadBox Configurations Successfully Changed"
        return 0
    else
        az_log br "Error: Some DloadBox Configurations Failed to Change"
        return 1
    fi


}
config_changer_info(){
    az_log b "Changing dloadbox-info file..."
    if [[ -z "$CONFIG_FILEBROWSER_PASSWORD" ]]; then
        CONFIG_FILEBROWSER_PASSWORD="This Password only shows after first installation"
    fi
    true > "$file_dloadbox_info"
    {
        echo "############################################################"
        echo "#                                                          #"
        echo "#        !!! DO NOT EDIT THIS FILE MANUALLY !!!            #"
        echo "#                                                          #"
        echo "############################################################"
        echo "# This file is automatically generated and managed by DloadBOX."
        echo "# Manual changes to this file will have no effect "
        echo "# On DloadBOX settings and may cause errors."
        echo "# To modify DloadBOX settings:"
        echo "# Run the 'dloadbox' command in your terminal and follow the setup process."
        echo "############################################################"
        echo
        echo "############################################################"
        echo "##             DloadBox Infor for Users                   ##"
        echo "############################################################"
        echo
        echo "Download Manager"
        echo "----------------------------------------"
        echo "WEB_GUI_URL=$CONFIG_ARIANG_URL"
        echo "WEB_GUI_PORT=$CONFIG_WEBSERVER_PORT"
        echo
        echo "File Browser"
        echo "----------------------------------------"
        echo "FILE_BROWSER_URL=http://${CONFIG_IP_MAIN}:${CONFIG_FILEBROWSER_PORT}"
        echo "FILE_BROWSER_USERNAME=$CONFIG_FILEBROWSER_USERNAME"
        echo "FILE_BROWSER_PASSWORD=$CONFIG_FILEBROWSER_PASSWORD"
        echo
        echo "Telegram Bot"
        echo "----------------------------------------"
        echo "TELEGRAM_BOT_USERNAME=@${CONFIG_TELEGRAMBOT_BOT_USERNAME}"
        echo "TELEGRAM_BOT_TOKEN=$CONFIG_TELEGRAMBOT_BOT_TOKEN"
        echo "TELEGRAM_BOT_LIMIT_PERMISSION=$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION"
        echo "TELEGRAM_BOT_ALLOWED_USERNAMES=$CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
        echo
        echo "############################################################"
        echo "##             DloadBox Internal Variables                ##"
        echo "############################################################"
        echo "# Versions"
        echo "VERSION_DLOADBOX=$VERSION_DLOADBOX"
        echo "VERSION_DLOADBOX_CREATE=$VERSION_DLOADBOX_CREATE"
        echo "VERSION_DLOADBOX_UPDATE=$VERSION_DLOADBOX_UPDATE"
        echo "VERSION_FILEBROWSER=$VERSION_FILEBROWSER"
        echo "VERSION_ARIANG=$VERSION_ARIANG"
        echo "# Network"
        echo "INTERNALCONFIG_IP_MAIN=$CONFIG_IP_MAIN"
        echo "INTERNALCONFIG_INTERFACE_MAIN=$CONFIG_INTERFACE_MAIN"
        echo "# Aria2 config"
        echo "INTERNALCONFIG_ARIA2_RPC_SECRET=$CONFIG_ARIA2_RPC_SECRET"
        echo "INTERNALCONFIG_ARIA2_RPC_LISTEN_PORT=$CONFIG_ARIA2_RPC_LISTEN_PORT"
        echo "# Telegram Bot Config"
        echo "INTERNALCONFIG_TELEGRAMBOT_LIMIT_PERMISSION=$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION"
        echo "INTERNALCONFIG_TELEGRAMBOT_ALLOWED_USERNAMES=$CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
        echo "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET=$CONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET"
        echo "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_URL=$CONFIG_TELEGRAMBOT_ARIA2_RPC_URL"
        echo "INTERNALCONFIG_TELEGRAMBOT_BOT_TOKEN=$CONFIG_TELEGRAMBOT_BOT_TOKEN"
        echo "INTERNALCONFIG_TELEGRAMBOT_BOT_USERNAME=$CONFIG_TELEGRAMBOT_BOT_USERNAME"
        echo "# Webserver config"
        echo "INTERNALCONFIG_WEBSERVER_PORT=$CONFIG_WEBSERVER_PORT"
        echo "# Filebrowser config"
        echo "INTERNALCONFIG_FILEBROWSER_PASSWORD=$CONFIG_FILEBROWSER_PASSWORD"
        echo "INTERNALCONFIG_FILEBROWSER_PASSWORD_HASH=$CONFIG_FILEBROWSER_PASSWORD_HASH"
        echo "INTERNALCONFIG_FILEBROWSER_USERNAME=$CONFIG_FILEBROWSER_USERNAME"
        echo "INTERNALCONFIG_FILEBROWSER_PORT=$CONFIG_FILEBROWSER_PORT"
        echo "# AriaNG config"
        echo "INTERNALCONFIG_ARIANG_URL=$CONFIG_ARIANG_URL"
        echo "INTERNALCONFIG_ARIANG_RPC_SECRET_HASH=$CONFIG_ARIANG_RPC_SECRET_HASH"
    } >> "$file_dloadbox_info"
    az_log bg "DloadBox Info file successfully changed"
    return 0
}
menu_main() {
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
            menu_info
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
            menu_main
            ;;
    esac
}
menu_info
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
    az_log b "First Let's check if DloadBox Files and Directories are OK"
    sleep 2
    check_hierarchy
    if [[ "$CHECK_HIERARCHY_ISOK" == "false" ]]; then
        az_log br "Error: Some DloadBox Files and Directories are missing, can't Continue"
        exit 1
    fi
    az_log b "----------------------------------------"
    az_log b "✨ System is ready to go..."
    sleep 1
    az_log b "🚀 Launching main menu..."
    sleep 3
    menu_main
}
main
