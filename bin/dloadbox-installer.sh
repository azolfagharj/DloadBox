#!/bin/bash
# DloadBox Installer
# DloadBox is a complete download management platform combining aria2c, Lighttpd, ariaNG, RPC integration, and a Telegram bot.
# It offers a user-friendly web interface and remote control, enabling efficient and scalable management of downloads from anywhere.

# Version info
VERSION_DLOADBOX="alpha-2.2.9"
VERSION_DLOADBOX_CREATE="2024-12-01"
VERSION_DLOADBOX_UPDATE="2025-04-17"
VERSION_FILEBROWSER="2.31.2"
VERSION_ARIANG="1.3.9"
VERSION_CADDY="2.9.1"
VERSION_ARIA2C="1.37.0"
# Log file
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
#Detect Demo mode
DEMO_MODE=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --demo) DEMO_MODE=true ;;
    esac
    shift
done
#
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
    echo " Version:   $VERSION_DLOADBOX                       "
    echo " Since:     $VERSION_DLOADBOX_CREATE                "
    echo " Updated:   $VERSION_DLOADBOX_UPDATE                "
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
    PKG_DEP="tar wget curl make bzip2 gzip wget unzip sudo "
    URL_DLOADBOX="https://github.com/azolfagharj/DloadBox/releases/download/$VERSION_DLOADBOX/dloadbox.zip"
    URL_FILEBROWSER="https://github.com/filebrowser/filebrowser/releases/download/v$VERSION_FILEBROWSER/linux-amd64-filebrowser.tar.gz"
    URL_ARIANG="https://github.com/mayswind/AriaNg/releases/download/$VERSION_ARIANG/AriaNg-$VERSION_ARIANG-AllInOne.zip"
    URL_CADDY="https://github.com/caddyserver/caddy/releases/download/v$VERSION_CADDY/caddy_${VERSION_CADDY}_linux_amd64.tar.gz"
    DIR_INSTALL_SOURCE=$(dirname "$(realpath "$0")")/
    dir_dloadbox="/opt/dloadbox/"
    FILE_INSTALL_SCRIPT=$(basename "$0")
    CONFIG_FILEBROWSER_PORT="6803"
    CONFIG_ARIA2_RPC_LISTEN_PORT="6802"
    CONFIG_WEBSERVER_PORT="6801"
    # Caddy config
    CONFIG_CADDY_PASSWORD=""
    CONFIG_CADDY_PASSWORD_HASH=""
    CONFIG_CADDY_USERNAME=""
    if CONFIG_INTERFACE_MAIN=$(ip route | awk '/default/ {print $5}' | head -n 1); then
        az_log l "Main interface is: $CONFIG_INTERFACE_MAIN"
        if CONFIG_IP_MAIN=$(ip addr show "$CONFIG_INTERFACE_MAIN" | awk '/inet / {print $2}' | cut -d/ -f1 | head -n 1); then
            az_log l " IP is: $CONFIG_IP_MAIN"

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
    if command -v apt-get > /dev/null; then
        PKG_MGR="apt-get"
        PKG_CMD="apt-get install -y"
        apt-get update > /dev/null
    elif command -v dnf > /dev/null; then
        PKG_MGR="dnf"
        PKG_CMD="dnf install -y"
    elif command -v yum > /dev/null; then
        PKG_MGR="yum"
        PKG_CMD="yum install -y"
    elif command -v zypper > /dev/null; then
        PKG_MGR="zypper"
        PKG_CMD="zypper install -y"
    elif command -v pacman > /dev/null; then
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
    if $PKG_CMD $package > /dev/null; then
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
        if chown www-data:adm "$dir_dloadbox"/log/dloadbox-lighttpd-error.log &>/dev/null; then
            if chown www-data:adm "$dir_dloadbox"/config/dloadbox-lighttpd.conf &>/dev/null; then
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
    if ln -s "$dir_dloadbox"config/dloadbox-lighttpd.conf  /etc/lighttpd/conf-enabled/dloadbox-lighttpd.conf &>/dev/null; then
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
    if check_port "$CONFIG_WEBSERVER_PORT"; then
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
install_webserver2() {
    echo
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║    WebServer Installation and Configuration    ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Installing Caddy webserver"
    az_log b "Downloading Caddy Webserver..."
    wget -q --no-check-certificate -O caddy.tar.gz "$URL_CADDY" || wget  --no-check-certificate -O caddy.tar.gz "$URL_CADDY_TARGZ"
    if [[ -f caddy.tar.gz ]]; then
        az_log bg "Caddy have been successfully downloaded"
    else
        az_log br "There was an error in downloading Caddy"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Extracting Caddy Webserver..."
    if tar xzf caddy.tar.gz  > /dev/null; then
        az_log bg "Caddy have been successfully extracted"
    else
        az_log br "There was an error in extracting Caddy"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    if [[ -f caddy ]]; then
        az_log b "Moving Caddy Webserver..."
        if mv caddy /opt/dloadbox/bin/dloadbox-caddy &>/dev/null; then
            chmod 755 /opt/dloadbox/bin/dloadbox-caddy &>/dev/null
            mv LICENSE /opt/dloadbox/bin/LICENSE-CADDY &>/dev/null
            az_log bg "The web server has been successfully placed"
        else
            az_log br "There was an error in moving Caddy"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in finding Caddy binary"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    rm -rf caddy.tar.gz &>/dev/null
    rm -rf README.md &>/dev/null
    az_log b "---------------------------------"
    az_log b "Generating random password"
    sleep 1
    if CONFIG_CADDY_PASSWORD=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 25); then
        az_log bg "Password have been successfully generated"
        az_log b "Generating password hash"
        # for demo mode
        if [ "$DEMO_MODE" = true ]; then
            CONFIG_CADDY_PASSWORD="demo"
        fi
        if CONFIG_CADDY_PASSWORD_HASH=$(/opt/dloadbox/bin/dloadbox-caddy hash-password --plaintext "$CONFIG_CADDY_PASSWORD"); then
            az_log bg "Password hash have been successfully generated"
        else
            az_log br "There was an error in generating caddy password hash"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in generating caddy password"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Adding Password to config"
    if sed -i "s|XXX|$CONFIG_CADDY_PASSWORD_HASH|g" "/opt/dloadbox/config/dloadbox-caddy.conf" ; then
        az_log bg "Password have been successfully added to config"
    else
        az_log br "There was an error in adding password to config"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Setting up caddy service"
    if [[ -f "$dir_dloadbox"/services/dloadbox-caddy.service ]]; then
        az_log bg "Caddy service file found"
    else
        az_log br "There was an error in finding up caddy service file"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    if ln -s "$dir_dloadbox"services/dloadbox-caddy.service /etc/systemd/system/dloadbox-caddy.service &>/dev/null; then
        az_log bg "Service have been successfully created"
        systemctl daemon-reload &>/dev/null
    else
        az_log br "There was an error in creating service"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Starting caddy service"
    if systemctl start dloadbox-caddy &>/dev/null && systemctl is-active dloadbox-caddy &>/dev/null; then
        az_log bg "Caddy service started successfully"
    else
        az_log br "There was an error in starting caddy service"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Enabling caddy service"
    if systemctl enable dloadbox-caddy &>/dev/null; then
        az_log bg "Caddy service enabled successfully"
    else
        az_log br "There was an error in enabling caddy service"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log b "Checking Webserver port"
    sleep 2
    if check_port "$CONFIG_WEBSERVER_PORT"; then
        az_log bg "Webserver port is open"
    else
        az_log br "Webserver port is not open"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "---------------------------------"
    az_log bg "The installation and configuration of the Caddy web server was successful."
}
install_aria2() {
    echo
    az_log sg "╔═════════════════════════════════════════════════════╗"
    az_log sg "║   Download Manager Installation and Configuration   ║"
    az_log sg "╚═════════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Download Manager Installation and Configuration"
    #package_installer "aria2"
    if [[ ! -f /opt/dloadbox/bin/dloadbox-aria2c ]]; then
        az_log br "Can't find aria2c binary"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log bg "Aria2c binary is in place"
    az_log b "Setting aria2c binary permissions"
    chmod +x /opt/dloadbox/bin/dloadbox-aria2c &>/dev/null
    az_log bg "Aria2c binary permissions have been successfully set"
    sleep 1
    az_log b "---------------------------------"
    az_log b "Setting up aria2 config"
    sleep 1
    if [[ -f "$dir_dloadbox"config/dloadbox-aria2.conf ]]; then
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
    if CONFIG_ARIA2_RPC_SECRET=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 25); then
        az_log bg "rpc-secret have been successfully generated"
        az_log b "Configuring rpc-secret"
        sleep 1
        if sed -i "/rpc-secret=/c\rpc-secret=$CONFIG_ARIA2_RPC_SECRET" "$dir_dloadbox"config/dloadbox-aria2.conf &>/dev/null; then
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
    if [[ -f "$dir_dloadbox"/services/dloadbox-ariarpc.service ]]; then
        az_log bg "Aria2 service file found"
        az_log b "Creating service"
        if ln -s "$dir_dloadbox"services/dloadbox-ariarpc.service /etc/systemd/system/dloadbox-ariarpc.service &>/dev/null; then
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
    sleep 3
    if check_port "$CONFIG_ARIA2_RPC_LISTEN_PORT"; then
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
    if wget --no-check-certificate -q -O /opt/dloadbox/www/dloadbox-ariang.zip "$URL_ARIANG" || wget --no-check-certificate -O /opt/dloadbox/www/dloadbox-ariang.zip "$URL_ARIANG"; then
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
    if unzip -p /opt/dloadbox/www/dloadbox-ariang.zip "index.html" > /opt/dloadbox/www/dloadbox.html ; then
        unzip -p /opt/dloadbox/www/dloadbox-ariang.zip "LICENSE" > /opt/dloadbox/www/LICENSE
        az_log bg "AriaNG GUI have been successfully extracted"
    else
        az_log br "There was an error in extracting AriaNG GUI"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    if rm -rf /opt/dloadbox/www/dloadbox-ariang.zip  > /dev/null; then
        az_log bg "AriaNG GUI have been successfully removed"
    else
        az_log br "There was an error in removing AriaNG GUI zip file"
        az_log br "It's not a big deal"
        az_log br "But if you want to help us, Please open an issue in github"
        sleep 3
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
    if ln -s /opt/dloadbox/config/dloadbox-ariang.conf /opt/dloadbox/www/dloadbox-ariang.conf &>/dev/null; then
        az_log bg "dloadbox-ariang.conf symlink have been successfully created in www"
    else
        az_log br "There was an error in creating dloadbox-ariang.conf symlink"
        az_log br "Exiting script in 3 second..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
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
    # Remove tar file forcefully
    if rm -f dloadbox-filebrowser.tar.gz &>/dev/null; then
        az_log bg "Tar file removed successfully"
    else
        az_log br "There was an error in removing tar file"
        az_log br "It's not a big deal"
        az_log br "But if you want to help us, Please open an issue in github"
        sleep 3
    fi
    az_log b "---------------------------------"
    az_log b "Moving filebrowser LICENSE to the installation folder"
    sleep 1
    if mv LICENSE /opt/dloadbox/bin/LICENSE-FILEBROWSER &>/dev/null; then
        chmod 755 /opt/dloadbox/bin/LICENSE-FILEBROWSER &>/dev/null
        az_log bg "LICENSE have been successfully moved to: /opt/dloadbox/bin/LICENSE-FILEBROWSER"
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
    if CONFIG_FILEBROWSER_PASSWORD=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 25); then
        az_log bg "Password have been successfully generated"
        az_log b "making password hash"
        sleep 1
        # for demo mode
        if [ "$DEMO_MODE" = true ]; then
            CONFIG_FILEBROWSER_PASSWORD="demo"
        fi
        #
        if CONFIG_FILEBROWSER_PASSWORD_HASH=$(dloadbox-filebrowser hash "$CONFIG_FILEBROWSER_PASSWORD") &>/dev/null; then
            az_log bg "Password hash have been successfully created"
            az_log b "Configuring filebrowser"
            sleep 1
            if sed -i "/\"password\"/c\    \"password\": \"$CONFIG_FILEBROWSER_PASSWORD_HASH\"" /opt/dloadbox/config/dloadbox-filebrowser.json &>/dev/null; then
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
    if [[ -f "$dir_dloadbox"services/dloadbox-filebrowser.service ]]; then
        az_log bg "Filebrowser service file found"
        az_log b "Creating service"
        if ln -s "$dir_dloadbox"services/dloadbox-filebrowser.service /etc/systemd/system/dloadbox-filebrowser.service &>/dev/null; then
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
    if check_port "$CONFIG_FILEBROWSER_PORT"; then
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
        return 1
    fi


    # Check the port on localhost
    if (echo > /dev/tcp/127.0.0.1/"$port") &>/dev/null; then
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
        read -r -p "Please enter your Telegram bot token: " CONFIG_TELEGRAMBOT_BOT_TOKEN

        # Validate token format using regex
        if [[ $CONFIG_TELEGRAMBOT_BOT_TOKEN =~ ^[0-9]+:[-_a-zA-Z0-9]+$ ]]; then
            az_log bg "✅ Valid token format"
            break
        else
            az_log br "❌ Invalid token format. Please try again"
        fi
    done

    # Save token to config file
    if sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=${CONFIG_TELEGRAMBOT_BOT_TOKEN}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
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
                CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=false
                CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES="ALL"
                az_log b "You chose: Anyone can use the bot"
                break
                ;;
            2)
                CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=true
                az_log b "You chose: Only specific users can use the bot"
                break
                ;;
            *)
                az_log br "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
    if [[ "$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION" == "true" ]]; then
        sed -i '/LIMIT_PERMISSION/c\LIMIT_PERMISSION=true' /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null
        if grep -q "LIMIT_PERMISSION=true" /opt/dloadbox/config/dloadbox-telegrambot.conf; then
            az_log b "LIMIT_PERMISSION is set to true"
            az_log b "Enter the usernames of the users who can use the bot, separated by commas (without @) and case sensitive"
            az_log b "Example: username1,username2,username3"
            read -r -p "Enter the usernames: " CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES
            az_log b "Allowed usernames: $CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
            sed -i "s|^ALLOWED_USERNAMES=.*|ALLOWED_USERNAMES=${CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null
            if grep -q "$CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES" /opt/dloadbox/config/dloadbox-telegrambot.conf; then
                az_log bg "ALLOWED_USERNAMES is set to $CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
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
    if sed -i "s|^ARIA2_RPC_SECRET=.*|ARIA2_RPC_SECRET=token:${CONFIG_ARIA2_RPC_SECRET}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
        az_log bg "ARIA2_RPC_SECRET have been successfully set in bot config"
        if sed -i "s|^ARIA2_RPC_URL=.*|ARIA2_RPC_URL=http://${CONFIG_IP_MAIN}:${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
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
    if [[ -f "$dir_dloadbox"services/dloadbox-telegram.service ]]; then
        az_log bg "Telegram bot service file found"
        az_log b "Creating service"
        if ln -s "$dir_dloadbox"services/dloadbox-telegram.service /etc/systemd/system/dloadbox-telegram.service &>/dev/null; then
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
install_telegrambot2() {
    az_log sg "╔════════════════════════════════════════════════╗"
    az_log sg "║   Telegram Bot Installation and Configuration  ║"
    az_log sg "╚════════════════════════════════════════════════╝"
    echo
    sleep 1
    az_log l "Telegram Bot Installation and Configuration"
    az_log b "Checking /opt/dloadbox/bin/dloadbox-telegrambot ..."
    if [[ -f "/opt/dloadbox/bin/dloadbox-telegrambot" ]]; then
        az_log bg "Telegram bot binary file found"
        chmod +x /opt/dloadbox/bin/dloadbox-telegrambot
    else
        az_log br "Telegram bot binary file not found"
        az_log br "Exiting script in 3 seconds..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Checking service file"
    if [[ -f "/opt/dloadbox/services/dloadbox-telegrambot.service" ]]; then
        az_log bg "Service file found"
    else
        az_log br "Service file not found :/opt/dloadbox/services/dloadbox-telegrambot.service"
        az_log br "Exiting script in 3 seconds..."
        az_log br "Please open an issue in github"
        sleep 3
        exit 1
    fi
    az_log b "Checking config file"
    if [[ -f "/opt/dloadbox/config/dloadbox-telegrambot.conf" ]]; then
        az_log bg "Config file found"
    else
        az_log br "Config file not found :/opt/dloadbox/config/dloadbox-telegrambot.conf"
        az_log br "Exiting script in 3 seconds..."
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
    if [ "$DEMO_MODE" = true ]; then
        CONFIG_TELEGRAMBOT_BOT_TOKEN="xxxx"
    else
        while true; do
            read -r -p "Please enter your Telegram bot token: " CONFIG_TELEGRAMBOT_BOT_TOKEN

        # Validate token format using regex
        if [[ $CONFIG_TELEGRAMBOT_BOT_TOKEN =~ ^[0-9]+:[-_a-zA-Z0-9]+$ ]]; then
            az_log bg "✅ Valid token format"
            break
        else
                az_log br "❌ Invalid token format. Please try again"
            fi
        done
    fi

    # Save token to config file
    if sed -i "s|^BOT_TOKEN=.*|BOT_TOKEN=${CONFIG_TELEGRAMBOT_BOT_TOKEN}|" /opt/dloadbox/config/dloadbox-telegrambot.conf > /dev/null; then
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
    if [ "$DEMO_MODE" = true ]; then
        CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=false
        CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES="ALL"
    else
        while true; do
            read -r -p "Enter your choice (1 or 2): " choice

        case $choice in
            1)
                CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=false
                CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES="ALL"
                az_log b "You chose: Anyone can use the bot"
                break
                ;;
            2)
                CONFIG_TELEGRAMBOT_LIMIT_PERMISSION=true
                az_log b "You chose: Only specific users can use the bot"
                break
                ;;
            *)
                az_log br "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
    fi
    if [[ "$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION" == "true" ]]; then
        sed -i '/LIMIT_PERMISSION/c\LIMIT_PERMISSION=true' /opt/dloadbox/config/dloadbox-telegrambot.conf > /dev/null
        if grep -q "LIMIT_PERMISSION=true" /opt/dloadbox/config/dloadbox-telegrambot.conf; then
            az_log b "LIMIT_PERMISSION is set to true"
            az_log b "Enter the usernames of the users who can use the bot, separated by commas (without @) and case sensitive"
            az_log b "Example: username1,username2,username3"
            read -r -p "Enter the usernames: " CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES
            az_log b "Allowed usernames: $CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
            sed -i "s|^ALLOWED_USERNAMES=.*|ALLOWED_USERNAMES=${CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null
            if grep -q "$CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES" /opt/dloadbox/config/dloadbox-telegrambot.conf; then
                az_log bg "ALLOWED_USERNAMES is set to $CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
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
    if sed -i "s|^ARIA2_RPC_SECRET=.*|ARIA2_RPC_SECRET=token:${CONFIG_ARIA2_RPC_SECRET}|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
        az_log bg "ARIA2_RPC_SECRET have been successfully set in bot config"
        if sed -i "s|^ARIA2_RPC_URL=.*|ARIA2_RPC_URL=http://${CONFIG_IP_MAIN}:${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc|" /opt/dloadbox/config/dloadbox-telegrambot.conf &>/dev/null; then
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
    if [[ -f "$dir_dloadbox"services/dloadbox-telegrambot.service ]]; then
        az_log bg "Telegram bot service file found"
        az_log b "Creating service"
        if ln -s "$dir_dloadbox"services/dloadbox-telegrambot.service /etc/systemd/system/dloadbox-telegrambot.service > /dev/null; then
            az_log bg "Service have been successfully created"
            systemctl daemon-reload > /dev/null
            az_log b "Starting dloadbox-telegrambot service"
            sleep 1
            if systemctl start dloadbox-telegrambot > /dev/null; then
                if systemctl is-active dloadbox-telegrambot > /dev/null; then
                    az_log bg "dloadbox-telegrambot service started successfully"
                    az_log b "Enabling dloadbox-telegrambot service"
                    sleep 1
                    if systemctl enable dloadbox-telegrambot > /dev/null; then
                        az_log bg "dloadbox-telegrambot service enabled successfully"
                    else
                        az_log br "There was an error in enabling dloadbox-telegrambot service"
                        az_log br "Exiting script in 3 second..."
                        az_log br "Please open an issue in github"
                        sleep 3
                        exit 1
                    fi
                else
                    az_log br "There was an error in starting dloadbox-telegrambot service"
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
    reset && clear
    display_logo
    CONFIG_ARIANG_RPC_SECRET_HASH=$(echo -n "$CONFIG_ARIA2_RPC_SECRET" | base64 | tr '+/' '-_' | sed 's/=//g')
    CONFIG_TELEGRAMBOT_BOT_USERNAME=$(curl -s "https://api.telegram.org/bot$CONFIG_TELEGRAMBOT_BOT_TOKEN/getMe" | grep -o '"username":"[^"]*"' | sed -E 's/"username":"(.*)"/\1/')
    CONFIG_ARIANG_URL="http://${CONFIG_IP_MAIN}:${CONFIG_WEBSERVER_PORT}/dloadbox.html#!/settings/rpc/set/http/${CONFIG_IP_MAIN}/${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc/${CONFIG_ARIANG_RPC_SECRET_HASH}"
    echo -n "CONFIG_ARIANG_URL=$CONFIG_ARIANG_URL" >> /opt/dloadbox/config/dloadbox-ariang.conf
    # Display in terminal
    echo
    echo -e "${RED}╭─────────────────────╮${NC}"
    echo -e "${RED}│  ${YELLOW}🚀 DLOADBOX INFO${RED}   │${NC}"
    echo -e "${RED}╰─────────────────────╯${NC}"
    echo

    # Download Manager Section
    echo -e "${GREEN}▸ 📥 Download Manager${NC}"
    echo -e "  ${BLUE}•${NC} Web Interface: ${CYAN}http://${CONFIG_IP_MAIN}:${CONFIG_WEBSERVER_PORT}${NC}"
    echo -e "  ${BLUE}•${NC} Username: ${CYAN}dloadbox${NC}"
    echo -e "  ${BLUE}•${NC} Password: ${CYAN}$CONFIG_CADDY_PASSWORD${NC}"
    echo -e "  ${BLUE}•${NC} Features: Create and manage downloads via browser"
    echo

    # File Browser Section
    echo -e "${GREEN}▸ 📂 File Browser${NC}"
    echo -e "  ${BLUE}•${NC} URL: ${CYAN}http://${CONFIG_IP_MAIN}:${CONFIG_FILEBROWSER_PORT}${NC}"
    echo -e "  ${BLUE}•${NC} Username: ${CYAN}dloadboxadmin${NC}"
    echo -e "  ${BLUE}•${NC} Password: ${CYAN}$CONFIG_FILEBROWSER_PASSWORD${NC}"
    echo -e "  ${BLUE}•${NC} Features: Browse and manage downloaded files"
    echo

    # Telegram Bot Section
    echo -e "${GREEN}▸ 🤖 Telegram Bot${NC}"
    echo -e "  ${BLUE}•${NC} Bot: ${CYAN}@${CONFIG_TELEGRAMBOT_BOT_USERNAME}${NC}"
    echo -e "  ${BLUE}•${NC} Features: Send links directly to bot for downloading"
    echo

    # Save to file
    {
        echo
        echo "############################################################"
        echo "##             DloadBox Infor for Users                   ##"
        echo "############################################################"
        echo
        echo "Download Manager"
        echo "----------------------------------------"
        echo "WEB_GUI_URL=http://${CONFIG_IP_MAIN}:${CONFIG_WEBSERVER_PORT}"
        echo "WEB_GUI_USERNAME=dloadbox"
        echo "WEB_GUI_PASSWORD=$CONFIG_CADDY_PASSWORD"
        echo "WEB_GUI_PORT=$CONFIG_WEBSERVER_PORT"
        echo
        echo "File Browser"
        echo "----------------------------------------"
        echo "FILE_BROWSER_URL=http://${CONFIG_IP_MAIN}:${CONFIG_FILEBROWSER_PORT}"
        echo "FILE_BROWSER_USERNAME=dloadboxadmin"
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
        echo "VERSION_CADDY=$VERSION_CADDY"
        echo "# Network"
        echo "INTERNALCONFIG_IP_MAIN=$CONFIG_IP_MAIN"
        echo "INTERNALCONFIG_INTERFACE_MAIN=$CONFIG_INTERFACE_MAIN"
        echo "# Aria2 config"
        echo "INTERNALCONFIG_ARIA2_RPC_SECRET=$CONFIG_ARIA2_RPC_SECRET"
        echo "INTERNALCONFIG_ARIA2_RPC_LISTEN_PORT=$CONFIG_ARIA2_RPC_LISTEN_PORT"
        echo "# Telegram Bot Config"
        echo "INTERNALCONFIG_TELEGRAMBOT_LIMIT_PERMISSION=$CONFIG_TELEGRAMBOT_LIMIT_PERMISSION"
        echo "INTERNALCONFIG_TELEGRAMBOT_ALLOWED_USERNAMES=$CONFIG_TELEGRAMBOT_ALLOWED_USERNAMES"
        echo "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_SECRET=token:$CONFIG_ARIA2_RPC_SECRET"
        echo "INTERNALCONFIG_TELEGRAMBOT_ARIA2_RPC_URL=http://${CONFIG_IP_MAIN}:${CONFIG_ARIA2_RPC_LISTEN_PORT}/jsonrpc"
        echo "INTERNALCONFIG_TELEGRAMBOT_BOT_TOKEN=$CONFIG_TELEGRAMBOT_BOT_TOKEN"
        echo "INTERNALCONFIG_TELEGRAMBOT_BOT_USERNAME=$CONFIG_TELEGRAMBOT_BOT_USERNAME"
        echo "# Webserver config"
        echo "INTERNALCONFIG_WEBSERVER_PORT=$CONFIG_WEBSERVER_PORT"
        echo "INTERNALCONFIG_WEBSERVER_USERNAME=dloadbox"
        echo "INTERNALCONFIG_WEBSERVER_PASSWORD=$CONFIG_CADDY_PASSWORD"
        echo "INTERNALCONFIG_WEBSERVER_PORT=$CONFIG_CADDY_PASSWORD_HASH"
        echo "# Filebrowser config"
        echo "INTERNALCONFIG_FILEBROWSER_PASSWORD=$CONFIG_FILEBROWSER_PASSWORD"
        echo "INTERNALCONFIG_FILEBROWSER_PASSWORD_HASH=$CONFIG_FILEBROWSER_PASSWORD_HASH"
        echo "INTERNALCONFIG_FILEBROWSER_USERNAME=dloadboxadmin"
        echo "INTERNALCONFIG_FILEBROWSER_PORT=$CONFIG_FILEBROWSER_PORT"
        echo "# AriaNG config"
        echo "INTERNALCONFIG_ARIANG_URL=$CONFIG_ARIANG_URL"
        echo "INTERNALCONFIG_ARIANG_RPC_SECRET_HASH=$CONFIG_ARIANG_RPC_SECRET_HASH"
    } >> /opt/dloadbox/dloadbox-info
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
    firewall_config --allow "$CONFIG_WEBSERVER_PORT" "$CONFIG_ARIA2_RPC_LISTEN_PORT" "$CONFIG_FILEBROWSER_PORT"
    az_log b "Done"
    az_log b "---------------------------------"
    az_log b "Checking DloadBox default ports on your system..."
    sleep 1
    if check_port "$CONFIG_WEBSERVER_PORT"; then
        az_log br "Port $CONFIG_WEBSERVER_PORT is used by another application"
        az_log br "DloadBox need to use this port for web server"
        az_log br "Please clear port $CONFIG_WEBSERVER_PORT on your system and run installer again"
        az_log br "You can open an issue in github"
        sleep 3
        exit 1
    else
        az_log bg "Port $CONFIG_WEBSERVER_PORT is free"
    fi
    if check_port "$CONFIG_ARIA2_RPC_LISTEN_PORT"; then
        az_log br "Port $CONFIG_ARIA2_RPC_LISTEN_PORT is used by another application"
        az_log br "DloadBox need to use this port for aria2 rpc"
        az_log br "Please clear port $CONFIG_ARIA2_RPC_LISTEN_PORT on your system and run installer again"
        az_log br "You can open an issue in github"
        sleep 3
        exit 1
    else
        az_log bg "Port $CONFIG_ARIA2_RPC_LISTEN_PORT is free"
    fi
    if check_port "$CONFIG_FILEBROWSER_PORT"; then
        az_log br "Port $CONFIG_FILEBROWSER_PORT is used by another application"
        az_log br "DloadBox need to use this port for filebrowser"
        az_log br "Please clear port $CONFIG_FILEBROWSER_PORT on your system and run installer again"
        az_log br "You can open an issue in github"
        sleep 3
        exit 1
    else
        az_log bg "Port $CONFIG_FILEBROWSER_PORT is free"
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
    if mkdir -p dloadbox &>/dev/null; then
        if unzip dloadbox.zip -d dloadbox &>/dev/null; then
            az_log bg "The package has been successfully extracted"
        else
            az_log br "There was an error in extracting the package"
            az_log br "Exiting script in 3 second..."
            az_log br "Please open an issue in github"
            sleep 3
            exit 1
        fi
    else
        az_log br "There was an error in creating directory"
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
    az_log b "Cleaning up release zip file..."
    if rm -f dloadbox.zip &>/dev/null; then
        az_log bg "Zip file cleaned up successfully"
    else
        az_log br "There was an error in cleaning up zip file"
        az_log br "It's not a big deal but you can open an issue in github to help us improve the script"
        sleep 3
    fi

    if rm -rf dloadbox &>/dev/null; then
        az_log bg "Temporary installation directory cleaned up successfully"
    else
        az_log br "There was an error in cleaning up temporary installation directory"
        az_log br "It's not a big deal but you can open an issue in github to help us improve the script"
        sleep 3
    fi
    az_log b "---------------------------------"
    az_log b "Setting permissions"
    sleep 1
    if chmod 755 "$dir_dloadbox" &>/dev/null; then
        if find "$dir_dloadbox" -type d -exec chmod 755 {} \; &>/dev/null; then
            if find "$dir_dloadbox" -type f -exec chmod 644 {} \; &>/dev/null; then
                az_log bg "Permission have been successfully chenged"
                chmod +x "$dir_dloadbox/bin/dloadbox-manager.sh"
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
    install_webserver2
    az_log b "---------------------------------"
    sleep 2
    install_aria2
    az_log b "---------------------------------"
    sleep 2
    install_filebrowser
    az_log b "---------------------------------"
    sleep 2
    install_telegrambot2
    az_log b "---------------------------------"
    sleep 2
    install_ariang
    az_log b "---------------------------------"
    sleep 2
    if ln -s "$dir_dloadbox/bin/dloadbox-manager.sh" /bin/dloadbox &>/dev/null; then
        az_log bg "DloadBox manager link created successfully"
    else
        az_log br "There was an error in creating DloadBox manager link"
        az_log br "Please open an issue in github"
        sleep 3
    fi
    az_log b "________________________________________________________________________"
    az_log b "Installation completed successfully"
    az_log b "Gathering information for you..."
    sleep 2
}
dloadbox_uninstall() {
    az_log b "🗑️ Uninstalling DloadBox..."
    sleep 2

    az_log b "🔄 Removing services..."
    service_manager --remove lighttpd dloadbox-ariarpc dloadbox-filebrowser dloadbox-telegram dloadbox-caddy dloadbox-telegrambot

    az_log b "🗑️ Removing installed packages..."
    package_uninstaller "lighttpd aria2"
    sudo rm -rf /etc/lighttpd &>/dev/null
    sudo rm -rf /var/log/lighttpd  &>/dev/null
    sudo rm -rf /var/cache/lighttpd &>/dev/null
    rm -rf /usr/bin/*dloadbox* &>/dev/null
    rm -rf /etc/systemd/system/*dloadbox* &>/dev/null
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
    firewall_config --remove "$CONFIG_WEBSERVER_PORT" "$CONFIG_ARIA2_RPC_LISTEN_PORT" "$CONFIG_FILEBROWSER_PORT"
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