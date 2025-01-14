#!/bin/bash
# DloadBox Installer
# DloadBox is a complete download management platform combining aria2c, Lighttpd, ariaNG, RPC integration, and a Telegram bot.
# It offers a user-friendly web interface and remote control, enabling efficient and scalable management of downloads from anywhere.
# Version: 1.4.1
# Since:    2024-10-01
# Updated : 2024-12-27
# Log file
VERSION_NUMBER="alpha-2.0.0"
VERSION_CREATE="2024-12-01"
VERSION_UPDATE="2025-01-14"

LOG_FILE="./dloadbox-install.log"
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
    echo -e "${RED}│  INSTALLER  │${NC}"
    echo -e "${RED}╰─────────────╯${NC}"
    echo ""
}
# Function to display header information
display_header() {
    echo "===================================================="
    echo " Version:   $VERSION_NUMBER                       "
    echo " Since:     $VERSION_CREATE                       "
    echo " Updated:   $VERSION_UPDATE                       "
    echo "===================================================="
    echo " Developer: A.Zolfaghar                             "
    echo " Email:     azolfagharj@gmail.com                   "
    echo " Repo:      https://github.com/azolfagharj/DloadBox "
    echo "===================================================="
    echo ""
    sleep 1
}
init_log() {
# Create directories and log file if they do not exist
    if [ ! -d "/opt/dloadbox/log" ]; then
        # echo "Directory /opt/dloadbox/log does not exist, creating it..."
        if mkdir -p /opt/dloadbox/log; then
            # echo "Directory /opt/dloadbox created successfully."
            true >> "$LOG_FILE"
        else
             echo "Error creating /opt/dloadbox/log directory."
             sleep 1
             echo "Make sure you are sudo user, and run it again"
             echo "Exiting installation in 2 second"
             sleep 3
             exit 1
        fi
    fi
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
root_check() {
    # Check for root privileges
    if [ "$EUID" -ne 0 ]; then
        az_log br "Please run this script as root." >&2
        sleep 3
        exit 1
    fi
}
init_bsics(){
    az_log b "Checking system requirements and preparing environment..."
    sleep 2
    PKG_DEP="tar wget curl make bzip2 gzip wget unzip sudo netcat"
    URL_DLOADBOX="https://github.com/azolfagharj/DloadBox/releases/download/$VERSION_NUMBER/dloadbox.zip"
    URL_FILEBROWSER="https://github.com/filebrowser/filebrowser/releases/download/v2.31.2/linux-amd64-filebrowser.tar.gz"
    URL_ARIANG="https://github.com/mayswind/AriaNg/releases/download/1.3.8/AriaNg-1.3.8.zip"
    DIR_INSTALL_SOURCE=$(dirname "$(realpath "$0")")/
    DIR_INSTALL_DEST="/opt/dloadbox/"
    FILE_INSTALL_SCRIPT=$(basename "$0")
    PORT_FILEBROWSER="6803"
    PORT_RPC="6802"
    PORT_WEBSERVER="6801"
    if INTERFACE_MAIN=$(ip route | awk '/default/ {print $5}' | head -n 1); then
        az_log l "Main interface is: $INTERFACE_MAIN"
        if IP_MAIN=$(ip addr show "$INTERFACE_MAIN" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1); then
            az_log l " IP is: $IP_MAIN"

        else
            az_log br "Error: Unable to retrieve the main IP."

        fi

    else
        az_log br "Error: Unable to retrieve the main interface."
    fi

}
package_installer() {
    local package=$1

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        PKG_MGR="apt-get"
        PKG_CMD="apt-get install -y"
        apt-get update &>/dev/null
    elif command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
        PKG_CMD="dnf install -y"
    elif command -v yum &>/dev/null; then
        PKG_MGR="yum"
        PKG_CMD="yum install -y"
    elif command -v zypper &>/dev/null; then
        PKG_MGR="zypper"
        PKG_CMD="zypper install -y"
    elif command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
        PKG_CMD="pacman -S --noconfirm"
    else
        az_log br "❌ No supported package manager found"
        az_log br "Exiting script in 3 seconds..."
        az_log br "Please open an issue on GitHub"
        sleep 3
        exit 1
    fi
    # package name fix for pacman package manager
    if grep -q "netcat" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//netcat/gnu-netcat}
        fi
    fi
    if grep -q "python3" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//python3/python}
        fi
    fi
    if grep -q "python3-venv" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//python3-venv/python-virtualenv}
        fi
    fi
    if grep -q "python3-pip" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//python3-pip/python-pip}
        fi
    fi
    # Install package
    az_log b "📦 Installing '$package' using ${PKG_MGR}..."
    # shellcheck disable=SC2086
    if $PKG_CMD $package &>/dev/null; then
        az_log bg "✅ Package '$package' installed successfully"
    else
        az_log br "❌ Failed to install package: $package"
        az_log br "Please install it manually and run the script again"
        sleep 3
        exit 1
    fi
}
package_uninstaller() {
    local package=$1

    # Detect package manager
    if command -v apt-get &>/dev/null; then
        PKG_MGR="apt-get"
        PKG_CMD="apt-get purge -y"
        AUTOREMOVE_CMD="apt-get autoremove -y"
    elif command -v dnf &>/dev/null; then
        PKG_MGR="dnf"
        PKG_CMD="dnf remove -y"
        AUTOREMOVE_CMD="dnf autoremove -y"
    elif command -v yum &>/dev/null; then
        PKG_MGR="yum"
        PKG_CMD="yum remove -y"
        AUTOREMOVE_CMD="yum autoremove -y"
    elif command -v zypper &>/dev/null; then
        PKG_MGR="zypper"
        PKG_CMD="zypper remove -y"
        AUTOREMOVE_CMD="zypper clean"
    elif command -v pacman &>/dev/null; then
        PKG_MGR="pacman"
        PKG_CMD="pacman -R --noconfirm"
        AUTOREMOVE_CMD="pacman -Rns --noconfirm"
    else
        az_log br "❌ No supported package manager found"
        az_log br "Please open an issue on GitHub"
        sleep 3
        exit 1
    fi
    # package name fix for pacman package manager
    if grep -q "netcat" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//netcat/gnu-netcat}
        fi
    fi
    if grep -q "python3" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//python3/python}
        fi
    fi
    if grep -q "python3-venv" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//python3-venv/python-virtualenv}
        fi
    fi
    if grep -q "python3-pip" <<< "$package"; then
        if [[ "$PKG_MGR" == "pacman" ]]; then
            package=${package//python3-pip/python-pip}
        fi
    fi
    # Uninstall package
    az_log b "🗑️ Removing '$package' using ${PKG_MGR}..."
    # shellcheck disable=SC2086
    if $PKG_CMD $package &>/dev/null; then
        $AUTOREMOVE_CMD &>/dev/null
        az_log bg "✅ Package '$package' removed successfully"
    else
        az_log br "❌ Failed to remove package: $package"
        az_log br "Exiting script in 3 seconds..."
        az_log br "Please open an issue on GitHub"
        sleep 3
        exit 1
    fi
}


setup_user-group() {
    az_log b "Setting up dloadbox user and group..."

    # Remove existing user and group if they exist
    if id "dloadbox" &>/dev/null || grep -q "^dloadbox:" /etc/group; then
        az_log b "Found existing dloadbox user/group. Removing..."

        # First remove user if exists (must be done before group)
        if id "dloadbox" &>/dev/null; then
            if userdel dloadbox &>/dev/null; then
                az_log bg "Existing dloadbox user removed"
            else
                az_log br "Failed to remove dloadbox user"
                az_log br "Exiting script in 3 second..."
                az_log br "Please open an issue in github"
                sleep 3
                exit 1
            fi
        fi

        # Then remove group if exists
        if grep -q "^dloadbox:" /etc/group; then
            if groupdel dloadbox &>/dev/null; then
                az_log bg "Existing dloadbox group removed"
            else
                az_log br "Failed to remove dloadbox group"
                az_log br "Exiting script in 3 second..."
                az_log br "Please open an issue in github"
                sleep 3
                exit 1
            fi
        fi

        az_log b "---------------------------------"
    fi

    # Create new group
    if groupadd dloadbox &>/dev/null; then
        az_log bg "Group 'dloadbox' created successfully"
    else
        az_log br "Failed to create dloadbox group"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi

    # Create new user with the group
    if useradd -M -g dloadbox dloadbox -s /sbin/nologin &>/dev/null; then
        az_log bg "User 'dloadbox' created successfully"
    else
        az_log br "Failed to create dloadbox user"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        # Cleanup: remove the group if user creation fails
        groupdel dloadbox &>/dev/null
        sleep 3
        exit 1
    fi

    az_log bg "User and group setup completed successfully"
    sleep 1
}

install_webserver() {
    echo
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║    WebServer Installation and Configuration    ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Installing lighttpd webserver"
    if command -v lighttpd &> /dev/null; then
        az_log b "---------------------------------"
        az_log br "Lighttpd is already installed. This may conflict with DloadBox."
        az_log b "DloadBox needs a clean installation of lighttpd with its own configurations."
        echo
        read -r -p "Do you want to completely remove the current lighttpd and proceed with a fresh installation? (y/n): " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            az_log b "---------------------------------"
            systemctl stop lighttpd &>/dev/null
            systemctl disable lighttpd &>/dev/null

            if package_uninstaller "lighttpd"; then
                az_log b "---------------------------------"
                az_log b "Removing remaining lighttpd files..."
                sleep 1
                rm -rf /etc/lighttpd &>/dev/null
                rm -rf /var/log/lighttpd &>/dev/null
                rm -rf /var/cache/lighttpd &>/dev/null
                az_log bg "Remaining files have been removed successfully"
                az_log b "---------------------------------"
            else
                az_log br "Failed to remove lighttpd"
                sleep 3
                exit 1
            fi
        else
            az_log br "Installation cancelled by user"
            az_log br "Please remove lighttpd manually and try again"
            sleep 3
            exit 1
        fi
    fi
    package_installer "lighttpd"
    az_log b "---------------------------------"
    az_log b "Stoping lighttpd"
    sleep 1
    if  systemctl stop lighttpd &>/dev/null; then
        az_log b "lighttpd has been successfully stopped."
    else
        az_log br "There was an erorr in Stoping lighttpd"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Setting files permission..."
    sleep 1
    if chown -R www-data:www-data /opt/dloadbox/www &>/dev/null; then
        if chown www-data:adm "$DIR_INSTALL_DEST"/log/dloadbox-lighttpd-error.log &>/dev/null; then
            if chown www-data:adm "$DIR_INSTALL_DEST"/config/dloadbox-lighttpd.conf &>/dev/null; then
                az_log bg "Permission have been successfully chenged"
            else
                az_log br "There was an error in Setting permissions for lighttpd.conf"
                az_log br "Exiting script in 3 second..."
                az_log br "Please open an issue in github"
                sleep 3
                exit 1
            fi
        else
            az_log br "There was an error in Setting permissions for error.log"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in Setting permissions"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Creting wbserver config..."
    sleep 1
    if ln -s "$DIR_INSTALL_DEST"config/dloadbox-lighttpd.conf  /etc/lighttpd/conf-enabled/dloadbox-lighttpd.conf &>/dev/null; then
        if sed -i '/server.document-root/s/^/#/' /etc/lighttpd/lighttpd.conf &>/dev/null; then
            if sed -i '/server.errorlog/s/^/#/' /etc/lighttpd/lighttpd.conf &>/dev/null; then
                if sed -i '/server.port/s/^/#/' /etc/lighttpd/lighttpd.conf &>/dev/null; then
                    az_log bg "Webserver config have been successfully created"
                    az_log b "---------------------------------"
                    az_log b "Starting lighttpd..."
                    if systemctl start lighttpd &>/dev/null; then
                        if systemctl is-active lighttpd &>/dev/null; then
                            az_log bg "lighttpd started"
                            az_log b "---------------------------------"
                            az_log b "Enabling lighttpd..."
                            if systemctl enable lighttpd &>/dev/null; then
                                az_log bg "lighttpd enabled successfully"
                            else
                                az_log br "Error enabling lighttpd service"
                                az_log br "Exiting script in 3 second..."
                                az_log br "Please open an issue in github"
                                sleep 3
                                exit 1
                            fi
                        else
                            az_log br "There was an error in starting lighttpd"
                            az_log br "Exiting script in 3 second..."
                            az_log br "Please open an issue in github"
                            sleep 3
                            exit 1
                        fi
                    else
                        az_log br "There was an error in restarting lighttpd"
                        az_log br "Exiting script in 3 second..."
                        az_log br "Please open an issue in github"
                        sleep 3
                        exit 1
                    fi
                else
                    az_log br "Error modifying server.port in lighttpd.conf"
                    az_log br "Exiting script in 3 second..."
                    az_log br "Please open an issue in github"
                    sleep 3
                    exit 1
                fi
            else
                az_log br "Error modifying server.errorlog in lighttpd.conf"
                az_log br "Exiting script in 3 second..."
                az_log br "Please open an issue in github"
                sleep 3
                exit 1
            fi
        else
            az_log br "Error modifying server.document-root in lighttpd.conf"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in Creating webserver config"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Checking webserver port"
    sleep 5
    if check_port "$PORT_WEBSERVER"; then
        az_log bg "Webserver port is open"
    else
        az_log br "Webserver port is not open"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log bg "The installation and configuration of the lighttpd web server was successful."
}

install_aria2() {
    echo
    az_log sg "╔═════════════════════════════════════════════════════╗"
    az_log sg "║   Download Manager Installation and Configuration   ║"
    az_log sg "╚═════════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Download Manager Installation and Configuration"
    package_installer "aria2"
    az_log b "---------------------------------"
    az_log b "Setting up aria2 config"
    sleep 1
    if [[ -f "$DIR_INSTALL_DEST"config/dloadbox-aria2.conf ]]; then
        az_log bg "Aria2 config found"
    else
        az_log br "There was an error in finding up aria2 config"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Generating random rpc-secret"
    sleep 1
    if SECRET_RPC=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 25); then
        az_log bg "rpc-secret have been successfully generated"
        az_log b "Configuring rpc-secret"
        sleep 1
        if sed -i "/rpc-secret=/c\rpc-secret=$SECRET_RPC" "$DIR_INSTALL_DEST"config/dloadbox-aria2.conf &>/dev/null; then
            az_log bg "rpc-secret have been successfully configured"
        else
            az_log br "There was an error in configuring rpc-secret"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in generating rpc-secret"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Setting up aria2 service"
    sleep 1
    if [[ -f "$DIR_INSTALL_DEST"/services/dloadbox-ariarpc.service ]]; then
        az_log bg "Aria2 service file found"
        az_log b "Creating service"
        if ln -s "$DIR_INSTALL_DEST"services/dloadbox-ariarpc.service /etc/systemd/system/dloadbox-ariarpc.service &>/dev/null; then
            az_log bg "Service have been successfully created"
            systemctl daemon-reload &>/dev/null
            az_log b "Starting dloadbox-ariarpc service"
            sleep 1
            if systemctl start dloadbox-ariarpc &>/dev/null; then
                if systemctl is-active dloadbox-ariarpc &>/dev/null; then
                    az_log bg "dloadbox-ariarpc service started successfully"
                    az_log b "Enabling dloadbox-ariarpc service"
                    sleep 1
                    if systemctl enable dloadbox-ariarpc &>/dev/null; then
                        az_log bg "dloadbox-ariarpc service enabled successfully"
                    else
                        az_log br "There was an error in enabling dloadbox-ariarpc service"
                        az_log br "Exiting script in 3 second..."
                        az_log br "Please open an issue in github"
                        sleep 3
                        exit 1
                    fi
                else
                    az_log br "There was an error in starting dloadbox-ariarpc service"
                    az_log br "Exiting script in 3 second..."
                    az_log br "Please open an issue in github"
                    sleep 3
                    exit 1
                fi
            else
                az_log br "There was an error in starting dloadbox-ariarpc service"
                az_log br "Exiting script in 3 second..."
                az_log br "Please open an issue in github"
                sleep 3
                exit 1
            fi
        else
            az_log br "There was an error in creating service"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in finding up aria2 service file"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Checking aria2 rpc port"
    sleep 1
    if check_port "$PORT_RPC"; then
        az_log bg "Aria2 rpc port is open"
    else
        az_log br "Aria2 rpc port is not open"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log bg "The installation and configuration of the aria2  and RPC service was successful."
}
install_ariang() {
    echo
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║    AriaNG Installation and Configuration       ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Installing AriaNG GUI"
    az_log b "Downloading AriaNG GUI..."
    sleep 1
    if wget --no-check-certificate -q -O /opt/dloadbox/www/dloadbox-ariang.zip "$URL_ARIANG" &>/dev/null; then
        az_log bg "AriaNG GUI have been successfully downloaded"
    else
        az_log br "There was an error in downloading AriaNG GUI"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Extracting AriaNG GUI..."
    sleep 1
    if unzip -q /opt/dloadbox/www/dloadbox-ariang.zip -d /opt/dloadbox/www/ &>/dev/null; then
        az_log bg "AriaNG GUI have been successfully extracted"
    else
        az_log br "There was an error in extracting AriaNG GUI"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    sleep 1
    az_log b "Setting up AriaNG GUI Permissions"
    sleep 1
    find /opt/dloadbox/www/ -type f -exec chmod 644 {} \;
    find /opt/dloadbox/www/ -type d -exec chmod 755 {} \;
    chown -R www-data:www-data /opt/dloadbox/www/
    az_log bg "AriaNG GUI Permissions have been successfully set"
    az_log b "---------------------------------"
    az_log b "Cleaning up..."
    sleep 1
    if rm -rf /opt/dloadbox/www/dloadbox-ariang.zip &>/dev/null; then
        az_log bg "Cleanup completed"
    else
        az_log br "There was an error in cleaning up"
        az_log br "It's not big deal"
        az_log br "But if you want to help us, Please open an issue in github"
        sleep 3
    fi
    az_log b "---------------------------------"
    az_log bg "The installation and configuration of the AriaNG GUI was successful."
}
install_filebrowser() {
    echo
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║   FileBrowser Installation and Configuration   ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Installing filebrowser"
    az_log b "Downloading filebrowser..."
    sleep 1
    if wget -q --no-check-certificate -O dloadbox-filebrowser.tar.gz "$URL_FILEBROWSER" &>/dev/null; then
        sleep 1
        az_log bg "File: dloadbox-filebrowser.tar.gz Downloaded"
    else
        az_log br "There was an error in downloading filebrowser"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Extracting filebrowser package..."
    sleep 1
    if tar -xzf dloadbox-filebrowser.tar.gz filebrowser LICENSE &>/dev/null; then
        az_log bg "The package has been successfully extracted"
    else
        az_log br "There was an error in extracting the package"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Moving filebrowser to the installation folder"
    sleep 1
    if mv filebrowser /opt/dloadbox/bin/dloadbox-filebrowser &>/dev/null; then
        chmod 755 /opt/dloadbox/bin/dloadbox-filebrowser &>/dev/null
        az_log bg "Filebrowser have been successfully moved to: /opt/dloadbox/bin/dloadbox-filebrowser"
        az_log b "Creating symlink to /usr/bin/dloadbox-filebrowser"
        sleep 1
        if ln -s /opt/dloadbox/bin/dloadbox-filebrowser /usr/bin/dloadbox-filebrowser &>/dev/null; then
            az_log bg "Symlink have been successfully created"
        else
            az_log br "There was an error in creating symlink"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in moving filebrowser"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Moving filebrowser LICENSE to the installation folder"
    sleep 1
    if mv LICENSE /opt/dloadbox/bin/dloadbox-filebrowser-LICENSE &>/dev/null; then
        chmod 755 /opt/dloadbox/bin/dloadbox-filebrowser-LICENSE &>/dev/null
        az_log bg "LICENSE have been successfully moved to: /opt/dloadbox/bin/dloadbox-filebrowser-LICENSE"
    else
        az_log br "There was an error in moving LICENSE"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Generating randop password for filebrowser"
    sleep 1
    if PASSWORD_FILEBROWSER=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 25); then
        az_log bg "Password have been successfully generated"
        az_log b "making password hash"
        sleep 1
        if PASSWORD_FILEBROWSER_HASH=$(dloadbox-filebrowser hash "$PASSWORD_FILEBROWSER") &>/dev/null; then
            az_log bg "Password hash have been successfully created"
            az_log b "Configuring filebrowser"
            sleep 1
            if sed -i "/\"password\"/c\    \"password\": \"$PASSWORD_FILEBROWSER_HASH\"" /opt/dloadbox/config/dloadbox-filebrowser.json &>/dev/null; then
                az_log bg "filebrowser  have been successfully configured"
            else
                az_log br "There was an error in configuring filebrowser "
                az_log br "Exiting script in 3 second..."
                az_log br "Please open an issue in github"
                sleep 3
                exit 1
            fi
        else
            az_log br "There was an error in creating password hash"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in generating password"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Setting up filebrowser service"
    sleep 1
    if [[ -f "$DIR_INSTALL_DEST"services/dloadbox-filebrowser.service ]]; then
        az_log bg "Filebrowser service file found"
        az_log b "Creating service"
        if ln -s "$DIR_INSTALL_DEST"services/dloadbox-filebrowser.service /etc/systemd/system/dloadbox-filebrowser.service &>/dev/null; then
            az_log bg "Service have been successfully created"
            systemctl daemon-reload &>/dev/null
            az_log b "Starting dloadbox-filebrowser service"
            sleep 1
            if systemctl start dloadbox-filebrowser &>/dev/null; then
                if systemctl is-active dloadbox-filebrowser &>/dev/null; then
                    az_log bg "dloadbox-filebrowser service started successfully"
                    az_log b "Enabling dloadbox-filebrowser service"
                    sleep 1
                    if systemctl enable dloadbox-filebrowser &>/dev/null; then
                        az_log bg "dloadbox-filebrowser service enabled successfully"
                    else
                        az_log br "There was an error in enabling dloadbox-filebrowser service"
                        az_log br "Exiting script in 3 second..."
                        az_log br "Please open an issue in github"
                        sleep 3
                        exit 1
                    fi
                else
                    az_log br "There was an error in starting dloadbox-filebrowser service"
                    az_log br "Exiting script in 3 second..."
                    az_log br "Please open an issue in github"
                    sleep 3
                    exit 1
                fi
            fi
        else
            az_log br "There was an error in creating service"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in finding up filebrowser service file"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Checking filebrowser port"
    sleep 1
    if check_port "$PORT_FILEBROWSER"; then
        az_log bg "Filebrowser port is open"
    else
        az_log br "Filebrowser port is not open"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log bg "The installation and configuration of the filebrowser was successful."
}

check_port() {
    local port=$1

    # Check if port is provided
    if [[ -z $port ]]; then
        az_log br "Error: No port number provided." >&2
        return 2
    fi

    # Check if nc is available
    if ! command -v nc &>/dev/null; then
        az_log br "Error: 'nc' command not found." >&2
        return 3
    fi

    # Check the port on localhost
    if nc -z -v localhost "$port" &>/dev/null; then

        return 0
    else

        return 1
    fi
}
install_telegrambot() {
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║   Telegram Bot Installation and Configuration  ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Telegram Bot Installation and Configuration"
    az_log b "Installing python3 python3-pip python3-venv..."
    sleep 1
    if package_installer "python3 python3-pip python3-venv" ; then
        az_log bg "Telegram bot have been successfully installed"
    else
        az_log br "There was an error in installing telegram bot"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Creating virtual environment"
    sleep 1
    if python3 -m venv /opt/dloadbox/venv/dloadbox-telegrambot ; then
        az_log bg "Virtual environment have been successfully created"
    else
        az_log br "There was an error in creating virtual environment"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Activating virtual environment"
    sleep 1
    if source /opt/dloadbox/venv/dloadbox-telegrambot/bin/activate 1>/dev/null; then
        az_log bg "Virtual environment have been successfully activated"
        /opt/dloadbox/venv/dloadbox-telegrambot/bin/python3 -m pip install --upgrade pip 1>/dev/null
        az_log b "Installing bot dependencies by pip"
        sleep 1
        if /opt/dloadbox/venv/dloadbox-telegrambot/bin/pip3 install requests python-telegram-bot 1>/dev/null; then
            az_log bg "Bot dependencies have been successfully installed"
            deactivate
        else
            az_log br "There was an error in installing bot dependencies"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            deactivate
            sleep 3
            exit 1
        fi

    else
        az_log br "There was an error in activating virtual environment"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Configuring telegram bot"
    sleep 1
    az_log b "To create a Telegram bot:"
    az_log b "1. Message @BotFather on Telegram"
    az_log b "2. Send the /newbot command"
    az_log b "3. Enter your bot's name and username"
    az_log b "4. Copy the bot token that looks like this:"
    az_log b "Example: 123456789:FAKE_TOKEN_DO_NOT_USE_THIS_12345678"
    echo

    while true; do
        read -r -p "Please enter your Telegram bot token: " BOT_TOKEN

        # Validate token format using regex
        if [[ $BOT_TOKEN =~ ^[0-9]+:[-_a-zA-Z0-9]+$ ]]; then
            az_log bg "✅ Valid token format"
            break
        else
            az_log br "❌ Invalid token format. Please try again"
        fi
    done

    # Save token to config file
    if sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=${BOT_TOKEN}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
        az_log bg "Bot token successfully saved"
    else
        az_log br "Error saving bot token"
        az_log br "Exiting script in 3 seconds..."
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Setting Telegram bot privacy"
    az_log s "Please select the privacy level for your Telegram bot:"
    az_log s "1 - Anyone can use the bot"
    az_log s "2 - Only specific users can use the bot"

    while true; do
        read -r -p "Enter your choice (1 or 2): " choice

        case $choice in
            1)
                LIMIT_PERMISSION=false
                az_log b "You chose: Anyone can use the bot"
                break
                ;;
            2)
                LIMIT_PERMISSION=true
                az_log b "You chose: Only specific users can use the bot"
                break
                ;;
            *)
                az_log br "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
    if [[ "$LIMIT_PERMISSION" == "true" ]]; then
        sed -i '/LIMIT_PERMISSION/c\LIMIT_PERMISSION=true' /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null
        if grep -q "LIMIT_PERMISSION=true" /opt/dloadbox/config/dloadbox-telegrambot.conf; then
            az_log b "LIMIT_PERMISSION is set to true"
            az_log b "Enter the usernames of the users who can use the bot, separated by commas (without @) and case sensitive"
            az_log b "Example: username1,username2,username3"
            read -r -p "Enter the usernames: " ALLOWED_USERNAMES
            az_log b "Allowed usernames: $ALLOWED_USERNAMES"
            sed -i "s|^ALLOWED_USERNAMES=.*|ALLOWED_USERNAMES=${ALLOWED_USERNAMES}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null
            if grep -q "$ALLOWED_USERNAMES" /opt/dloadbox/config/dloadbox-telegrambot.conf; then
                az_log bg "ALLOWED_USERNAMES is set to $ALLOWED_USERNAMES"
            else
                az_log br "There was an error in setting ALLOWED_USERNAMES"
                az_log br "Please open an issue in github"
                az_log b "You can try to set it manually in /opt/dloadbox/config/dloadbox-telegrambot.conf"
                sleep 3
            fi
        else
            az_log br "There was an error in setting LIMIT_PERMISSION"
            az_log br "Please open an issue in github"
            az_log b "You can try to set it manually in /opt/dloadbox/config/dloadbox-telegrambot.conf"
            sleep 3
        fi
    fi
    az_log b "---------------------------------"
    az_log b "Setting up Aria RPC related bot configuration"
    if sed -i "s|^ARIA2_RPC_SECRET=.*|ARIA2_RPC_SECRET=token:${SECRET_RPC}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
        az_log bg "ARIA2_RPC_SECRET have been successfully set in bot config"
        if sed -i "s|^ARIA2_RPC_URL=.*|ARIA2_RPC_URL=http://${IP_MAIN}:${PORT_RPC}/jsonrpc|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
            az_log bg "ARIA2_RPC_URL have been successfully set in bot config"
        else
            az_log br "There was an error in setting ARIA2_RPC_URL"
            az_log br "Please open an issue in github"
            az_log b "You can try to set it manually in /opt/dloadbox/config/dloadbox-telegrambot.conf"
            sleep 3
        fi
    else
        az_log br "There was an error in setting ARIA_RPC_SECRET"
        az_log br "Please open an issue in github"
        sleep 3
    fi
    az_log b "---------------------------------"
    az_log b "Setting up telegram bot service"
    sleep 1
    if [[ -f "$DIR_INSTALL_DEST"services/dloadbox-telegram.service ]]; then
        az_log bg "Telegram bot service file found"
        az_log b "Creating service"
        if ln -s "$DIR_INSTALL_DEST"services/dloadbox-telegram.service /etc/systemd/system/dloadbox-telegram.service &>/dev/null; then
            az_log bg "Service have been successfully created"
            systemctl daemon-reload &>/dev/null
            az_log b "Starting dloadbox-telegram service"
            sleep 1
            if systemctl start dloadbox-telegram &>/dev/null; then
                if systemctl is-active dloadbox-telegram &>/dev/null; then
                    az_log bg "dloadbox-telegram service started successfully"
                    az_log b "Enabling dloadbox-telegram service"
                    sleep 1
                    if systemctl enable dloadbox-telegram &>/dev/null; then
                        az_log bg "dloadbox-telegram service enabled successfully"
                    else
                        az_log br "There was an error in enabling dloadbox-telegram service"
                        az_log br "Exiting script in 3 second..."
                        az_log br "Please open an issue in github"
                        sleep 3
                        exit 1
                    fi
                else
                    az_log br "There was an error in starting dloadbox-telegram service"
                    az_log br "Exiting script in 3 second..."
                    az_log br "Please open an issue in github"
                    sleep 3
                    exit 1
                fi
            fi
        else
            az_log br "There was an error in creating service"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in finding up telegram bot service file"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
}
show_dloadbox_info() {
    ENCODED_SECRET=$(echo -n "$SECRET_RPC" | base64 | tr '+/' '-_' | sed 's/=//g')
    USERNAME_BOT=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getMe" | grep -o '"username":"[^"]*"' | sed -E 's/"username":"(.*)"/\1/')
    URL_ARIANG="http://${IP_MAIN}:${PORT_WEBSERVER}/#!/settings/rpc/set/http/${IP_MAIN}/${PORT_RPC}/jsonrpc/${ENCODED_SECRET}"

    # Display in terminal
    echo
    echo -e "${RED}╭─────────────────────╮${NC}"
    echo -e "${RED}│  ${YELLOW}🚀 DLOADBOX INFO${RED}   │${NC}"
    echo -e "${RED}╰─────────────────────╯${NC}"
    echo

    # Download Manager Section
    echo -e "${GREEN}▸ 📥 Download Manager${NC}"
    echo -e "  ${BLUE}•${NC} Web Interface: ${CYAN}$URL_ARIANG${NC}"
    echo -e "  ${BLUE}•${NC} Features: Create and manage downloads via browser"
    echo

    # File Browser Section
    echo -e "${GREEN}▸ 📂 File Browser${NC}"
    echo -e "  ${BLUE}•${NC} URL: ${CYAN}http://${IP_MAIN}:${PORT_FILEBROWSER}${NC}"
    echo -e "  ${BLUE}•${NC} Username: ${CYAN}dloadboxadmin${NC}"
    echo -e "  ${BLUE}•${NC} Password: ${CYAN}$PASSWORD_FILEBROWSER${NC}"
    echo -e "  ${BLUE}•${NC} Features: Browse and manage downloaded files"
    echo

    # Telegram Bot Section
    echo -e "${GREEN}▸ 🤖 Telegram Bot${NC}"
    echo -e "  ${BLUE}•${NC} Bot: ${CYAN}@${USERNAME_BOT}${NC}"
    echo -e "  ${BLUE}•${NC} Features: Send links directly to bot for downloading"
    echo

    # Save to file
    {
        echo "DLOADBOX INFO"
        echo "----------------------------------------"
        echo
        echo "Download Manager"
        echo "----------------------------------------"
        echo "Web Interface: $URL_ARIANG"
        echo "Features: Create and manage downloads via browser"
        echo
        echo "File Browser"
        echo "----------------------------------------"
        echo "URL: http://${IP_MAIN}:${PORT_FILEBROWSER}"
        echo "Username: dloadboxadmin"
        echo "Password: $PASSWORD_FILEBROWSER"
        echo "Features: Browse and manage downloaded files"
        echo
        echo "Telegram Bot"
        echo "----------------------------------------"
        echo "Bot: @${USERNAME_BOT}"
        echo "Features: Send links directly to bot for downloading"
    } > /opt/dloadbox/dloadbox-info
}
firewall_config() {
    local action=""
    local ports=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --allow|--remove)
                action="$1"
                shift
                ;;
            *)
                ports+=("$1")
                shift
                ;;
        esac
    done

    # Validate inputs
    if [ -z "$action" ]; then
        az_log br "❌ No action specified! Use --allow or --remove"
        return 1
    fi

    if [ ${#ports[@]} -eq 0 ]; then
        az_log br "❌ No ports specified!"
        return 1
    fi

    echo
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║           Configuring Firewall Rules           ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1

    # Check and configure UFW
    if command -v ufw >/dev/null 2>&1; then
        az_log b "🛡️  Configuring UFW firewall..."
        for port in "${ports[@]}"; do
            case "$action" in
                --allow)
                    if ufw status | grep -q "$port"; then
                        az_log bg "⚠️  Port $port is already allowed in UFW"
                    else
                        if ufw allow "$port/tcp" >/dev/null 2>&1; then
                            az_log bg "✅ Successfully allowed port $port in UFW"
                        else
                            az_log br "❌ Failed to allow port $port in UFW"
                        fi
                    fi
                    ;;
                --remove)
                    if ufw status | grep -q "$port"; then
                        if ufw delete allow "$port/tcp" >/dev/null 2>&1; then
                            az_log bg "🗑️  Successfully removed port $port from UFW"
                        else
                            az_log br "❌ Failed to remove port $port from UFW"
                        fi
                    else
                        az_log bg "⚠️  Port $port is not configured in UFW"
                    fi
                    ;;
            esac
        done
        ufw reload >/dev/null 2>&1
        az_log b "---------------------------------"
    fi

    # Check and configure firewalld
    if command -v firewall-cmd >/dev/null 2>&1; then
        az_log b "🛡️  Configuring firewalld..."
        if ! systemctl is-active --quiet firewalld; then
            systemctl start firewalld >/dev/null 2>&1
        fi
        for port in "${ports[@]}"; do
            case "$action" in
                --allow)
                    if firewall-cmd --list-ports | grep -q "$port/tcp"; then
                        az_log bg "⚠️  Port $port is already allowed in firewalld"
                    else
                        if firewall-cmd --permanent --add-port="$port/tcp" >/dev/null 2>&1; then
                            az_log bg "✅ Successfully allowed port $port in firewalld"
                        else
                            az_log br "❌ Failed to allow port $port in firewalld"
                        fi
                    fi
                    ;;
                --remove)
                    if firewall-cmd --list-ports | grep -q "$port/tcp"; then
                        if firewall-cmd --permanent --remove-port="$port/tcp" >/dev/null 2>&1; then
                            az_log bg "🗑️  Successfully removed port $port from firewalld"
                        else
                            az_log br "❌ Failed to remove port $port from firewalld"
                        fi
                    else
                        az_log bg "⚠️  Port $port is not configured in firewalld"
                    fi
                    ;;
            esac
        done
        firewall-cmd --reload >/dev/null 2>&1
        az_log b "---------------------------------"
    fi

    # Check and configure iptables
    if command -v iptables >/dev/null 2>&1; then
        az_log b "🛡️  Configuring iptables..."
        for port in "${ports[@]}"; do
            case "$action" in
                --allow)
                    if iptables -L INPUT -n | grep -q "dpt:$port"; then
                        az_log bg "⚠️  Port $port is already allowed in iptables"
                    else
                        if iptables -A INPUT -p tcp --dport "$port" -j ACCEPT >/dev/null 2>&1; then
                            az_log bg "✅ Successfully allowed port $port in iptables"
                        else
                            az_log br "❌ Failed to allow port $port in iptables"
                        fi
                    fi
                    ;;
                --remove)
                    if iptables -L INPUT -n | grep -q "dpt:$port"; then
                        if iptables -D INPUT -p tcp --dport "$port" -j ACCEPT >/dev/null 2>&1; then
                            az_log bg "🗑️  Successfully removed port $port from iptables"
                        else
                            az_log br "❌ Failed to remove port $port from iptables"
                        fi
                    else
                        az_log bg "⚠️  Port $port is not configured in iptables"
                    fi
                    ;;
            esac
        done

        # Save iptables rules for different systems
        if command -v iptables-save >/dev/null 2>&1; then
            if [ -d "/etc/iptables" ]; then
                iptables-save > /etc/iptables/rules.v4 2>/dev/null
            elif [ -f "/etc/sysconfig/iptables" ]; then
                iptables-save > /etc/sysconfig/iptables 2>/dev/null
            fi
        fi
        az_log b "---------------------------------"
    fi

    # If no supported firewall was found
    if ! command -v ufw >/dev/null 2>&1 && ! command -v firewall-cmd >/dev/null 2>&1 && ! command -v iptables >/dev/null 2>&1; then
        az_log br "❌ No supported firewall found on the system"
        return 1
    fi

    az_log bg "🎉 Firewall configuration completed successfully"
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
install_dloadbox() {
    if [ -d "/opt/dloadbox" ]; then
        az_log br "It seems that DloadBox is already installed on your system"
        echo -n "Do you want to uninstall DloadBox and install fresh one (y/n): "
        read -r uninstall_choice
        if [[ "$uninstall_choice" =~ ^[Yy]$ ]]; then
            dloadbox_uninstall
        else
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    fi
    echo
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║              Installing DloadBox               ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log b "Installing  required dependencies.."
    package_installer "$PKG_DEP"
    az_log b "---------------------------------"
    az_log b "Adding firewall rules..."
    firewall_config --allow "$PORT_WEBSERVER" "$PORT_RPC" "$PORT_FILEBROWSER"
    az_log b "Done"
    az_log b "---------------------------------"
    az_log b "Checking DloadBox default ports on your system..."
    sleep 1
    if check_port "$PORT_WEBSERVER"; then
        az_log br "Port $PORT_WEBSERVER is used by another application"
        az_log br "DloadBox need to use this port for web server"
        az_log br "Please clear port $PORT_WEBSERVER on your system and run installer again"
        az_log br "You can open an issue in github"
        sleep 3
        exit 1
    else
        az_log bg "Port $PORT_WEBSERVER is free"
    fi
    if check_port "$PORT_RPC"; then
        az_log br "Port $PORT_RPC is used by another application"
        az_log br "DloadBox need to use this port for aria2 rpc"
        az_log br "Please clear port $PORT_RPC on your system and run installer again"
        az_log br "You can open an issue in github"
        sleep 3
        exit 1
    else
        az_log bg "Port $PORT_RPC is free"
    fi
    if check_port "$PORT_FILEBROWSER"; then
        az_log br "Port $PORT_FILEBROWSER is used by another application"
        az_log br "DloadBox need to use this port for filebrowser"
        az_log br "Please clear port $PORT_FILEBROWSER on your system and run installer again"
        az_log br "You can open an issue in github"
        sleep 3
        exit 1
    else
        az_log bg "Port $PORT_FILEBROWSER is free"
    fi
    find . -name '*dloadbox*' ! -name "$FILE_INSTALL_SCRIPT" ! -name "dloadbox-install.log" -exec rm -rf {} \; 2>/dev/null
    az_log b "Downloading DloadBox repo..."
    if wget -q --no-check-certificate -O dloadbox.zip "$URL_DLOADBOX" &>/dev/null; then
        sleep 1
        az_log bg "File: dloadbox.zip Downloaded"
    else
        az_log br "There was an error in downloading with wget"
        az_log b "Retrying with curl..."
        rm -f dloadbox.zip > /dev/null
        if curl -s -k -L "$URL_DLOADBOX" -o dloadbox.zip &>/dev/null; then
            sleep 1
            az_log bg "File: dloadbox.zip Downloaded"
        else
            az_log br "There was an error in downloading file"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 1
            exit 1
        fi
    fi
    az_log b "---------------------------------"
    az_log b "Extracting the package"
    sleep 1
    if unzip dloadbox.zip &>/dev/null; then
        az_log bg "The package has been successfully extracted"
    else
        az_log br "There was an error in extracting the package"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Moving files to the installation folder."
    sleep 1
    if cp -rf dloadbox /opt/ &>/dev/null; then
        az_log bg "DloadBox files have been successfully moved to: /opt/dloadbox "
    else
        az_log br "There was an error in moving files"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Setting permissions"
    sleep 1
    if chmod 755 "$DIR_INSTALL_DEST" &>/dev/null; then
        if find "$DIR_INSTALL_DEST" -type d -exec chmod 755 {} \; &>/dev/null; then
            if find "$DIR_INSTALL_DEST" -type f -exec chmod 644 {} \; &>/dev/null; then
                az_log bg "Permission have been successfully chenged"
            fi
        fi
    else
        az_log br "There was an error in Setting permissions"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    setup_user-group
    az_log b "---------------------------------"
    sleep 1
    install_webserver
    az_log b "---------------------------------"
    sleep 2
    install_aria2
    az_log b "---------------------------------"
    sleep 2
    install_filebrowser
    az_log b "---------------------------------"
    sleep 2
    install_telegrambot
    sleep 2
    install_ariang
    az_log b "---------------------------------"
    sleep 2
    az_log b "________________________________________________________________________"
    az_log b "Installation completed successfully"
    az_log b "Gathering information for you..."
    sleep 2
}
dloadbox_uninstall() {
    az_log b "🗑️ Uninstalling DloadBox..."
    sleep 2

    az_log b "🔄 Removing services..."
    service_manager --remove lighttpd dloadbox-ariarpc dloadbox-filebrowser dloadbox-telegram

    az_log b "🗑️ Removing installed packages..."
    package_uninstaller "lighttpd aria2"
    sudo rm -rf /etc/lighttpd &>/dev/null
    sudo rm -rf /var/log/lighttpd  &>/dev/null
    sudo rm -rf /var/cache/lighttpd &>/dev/null
    rm -rf /usr/bin/*dloadbox* &>/dev/null
    az_log b "📂 Removing files..."
    rm -rf /opt/dloadbox &>/dev/null
    if [ ! -d "/opt/dloadbox" ]; then
        az_log bg "✅ Files removed successfully"
    else
        az_log br "❌ Failed to remove files"
    fi

    az_log b "👤 Removing user and group..."
    userdel -r dloadbox &>/dev/null
    groupdel dloadbox &>/dev/null
    if ! id "dloadbox" &>/dev/null && ! grep -q "^dloadbox:" /etc/group; then
        az_log bg "✅ User and group removed successfully"
    else
        az_log br "❌ Failed to remove user and group"
    fi

    if [ ! -d "/opt/dloadbox" ] && ! id "dloadbox" &>/dev/null && ! grep -q "^dloadbox:" /etc/group; then
        az_log bg "✅ Uninstallation completed successfully"
    else
        az_log br "❌ Uninstallation completed with some errors"
    fi
    az_log b "Removing firewall rules..."
    firewall_config --remove "$PORT_WEBSERVER" "$PORT_RPC" "$PORT_FILEBROWSER"
    az_log b "Done"
    az_log b "---------------------------------"
}
setup_static_header() {
    clear
    echo -e "\033[H"
    display_logo
    echo -e "\033[15;r"
    echo -e "\033[15;1H"
}

main() {
    setup_static_header
    display_header
    init_bsics
    az_log b "Done"
    install_dloadbox
    show_dloadbox_info
}
main
