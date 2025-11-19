#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# --- Desktop Environment Selection ---
DESKTOP_PACKAGE=""
DESKTOP_NAME=""

select_desktop_environment() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  Please select a desktop environment:${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo "1) XFCE     (Recommended, balanced features and performance)"
    echo "2) LXQt     (Lightweight, modern look and feel)"
    echo "3) Openbox  (Ultra-lightweight, minimal desktop)"
    echo -e "${BLUE}--------------------------------------------${NC}"
    while true; do
        read -p "Enter your choice (1-3): " choice
        case $choice in
            1)
                DESKTOP_PACKAGE="xfce4 xfce4-goodies"
                DESKTOP_NAME="XFCE"
                STARTUP_COMMAND="exec /usr/bin/startxfce4"
                break
                ;;
            2)
                DESKTOP_PACKAGE="lxqt"
                DESKTOP_NAME="LXQt"
                STARTUP_COMMAND="exec /usr/bin/startlxqt"
                break
                ;;
            3)
                DESKTOP_PACKAGE="openbox obconf"
                DESKTOP_NAME="Openbox"
                STARTUP_COMMAND="exec /usr/bin/openbox-session"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter a number between 1 and 3."
                ;;
        esac
    done
    print_status "You have chosen: $DESKTOP_NAME"
}

# --- Main Installation Logic ---

print_status "Starting the VNC Desktop setup script..."

# 0. Create a 2GB swap file to prevent out-of-memory errors
print_status "Creating a 2GB swap file for low-memory systems..."
if [ -f /swapfile ]; then
    print_warning "A swap file already exists. Skipping creation."
else
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    print_status "Swap file created and activated."
fi

# 1. Update system and install essentials
print_status "Updating system packages and installing essentials..."
apt-get update
apt-get install -y curl wget nano dbus dbus-x11

# 2. Select Desktop Environment
select_desktop_environment

# 3. Get username and password
while true; do
    read -p "Enter the username for the new desktop user: " NEW_USER
    if [[ "$NEW_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        break
    else
        print_error "Invalid username. Please use only lowercase letters, numbers, underscores, and hyphens, and it must not start with a number."
    fi
done

while true; do
    read -s -p "Enter the password for the new user: " PASSWORD
    echo
    read -s -p "Confirm the password: " PASSWORD_CONFIRM
    echo
    if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
        break
    else
        print_error "Passwords do not match. Please try again."
    fi
done

# 4. Create new user
if id "$NEW_USER" &>/dev/null; then
    print_warning "User '$NEW_USER' already exists. Skipping user creation."
else
    print_status "Creating new user: $NEW_USER"
    adduser --quiet --gecos "" --disabled-password "$NEW_USER"
    echo "$NEW_USER:$PASSWORD" | chpasswd
    usermod -aG sudo "$NEW_USER"
fi

# 4.5. Generate a unique machine ID for D-Bus
print_status "Generating a unique machine ID for D-Bus..."
if [ ! -s /etc/machine-id ]; then
    dbus-uuidgen | tee /etc/machine-id > /dev/null
    ln -sf /etc/machine-id /var/lib/dbus/machine-id
    print_status "Machine ID generated."
else
    print_warning "Machine ID already exists. Skipping generation."
fi

# 5. Install Desktop Environment
print_status "Installing $DESKTOP_NAME desktop environment... (This may take a while)"
apt-get install -y $DESKTOP_PACKAGE

# 6. Install VNC Server
print_status "Installing TigerVNC server..."
apt-get install -y tigervnc-standalone-server tigervnc-xorg-extension

# CRITICAL CHECK: Ensure vncpasswd is available
if ! command -v vncpasswd &> /dev/null; then
    print_error "TigerVNC installation seems incomplete (vncpasswd not found)."
    print_status "Attempting to install TightVNC server as a fallback..."
    apt-get install -y tightvncserver
    if ! command -v vncpasswd &> /dev/null; then
        print_error "Both VNC server installations failed. Cannot proceed."
        exit 1
    else
        print_status "TightVNC installed successfully as fallback."
    fi
else
    print_status "TigerVNC installed successfully."
fi

# 7. Install noVNC
print_status "Installing noVNC for browser access..."
NOVNC_VERSION=$(curl -s https://api.github.com/repos/novnc/noVNC/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
WEBTTY_VERSION=$(curl -s https://api.github.com/repos/novnc/websockify/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

print_status "Downloading noVNC ${NOVNC_VERSION} and websockify ${WEBTTY_VERSION}..."
cd /opt

wget "https://github.com/novnc/noVNC/archive/refs/tags/${NOVNC_VERSION}.tar.gz" -O novnc.tar.gz
tar -xvf novnc.tar.gz
NOVNC_DIR_NAME="noVNC-${NOVNC_VERSION#v}"
mv "$NOVNC_DIR_NAME" noVNC
rm novnc.tar.gz

wget "https://github.com/novnc/websockify/archive/refs/tags/${WEBTTY_VERSION}.tar.gz" -O websockify.tar.gz
tar -xvf websockify.tar.gz
WEBSOCKETIFY_DIR_NAME="websockify-${WEBTTY_VERSION#v}"
mv "$WEBSOCKETIFY_DIR_NAME" noVNC/utils/websockify
rm websockify.tar.gz

chmod +x /opt/noVNC/utils/novnc_proxy

# 8. Configure VNC for the new user
print_status "Configuring VNC for user '$NEW_USER'..."
VNC_DIR="/home/$NEW_USER/.vnc"
mkdir -p "$VNC_DIR"

echo "$PASSWORD" | vncpasswd -f > "$VNC_DIR/passwd"
chown -R "$NEW_USER:$NEW_USER" "$VNC_DIR"
chmod 600 "$VNC_DIR/passwd"

# xstartup script
cat << EOF > "$VNC_DIR/xstartup"
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
 $STARTUP_COMMAND
EOF
chmod +x "$VNC_DIR/xstartup"
chown "$NEW_USER:$NEW_USER" "$VNC_DIR/xstartup"

# 9. Create systemd service for VNC
print_status "Creating systemd service for VNC..."
cat << EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start VNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$NEW_USER
Group=$NEW_USER
WorkingDirectory=/home/$NEW_USER

ExecStart=/usr/bin/vncserver -depth 16 -geometry 1024x768 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

# 10. Create systemd service for noVNC proxy
print_status "Creating systemd service for noVNC..."
cat << EOF > /etc/systemd/system/novncproxy.service
[Unit]
Description=noVNC Proxy Service
After=network.target vncserver@1.service

[Service]
Type=simple
ExecStart=/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# 11. Install Google Chrome
print_status "Installing Google Chrome..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get install -y google-chrome-stable

# 12. Configure Firewall
print_status "Installing and configuring firewall (UFW)..."
if ! command -v ufw &> /dev/null; then
    print_status "UFW not found. Installing..."
    apt-get install -y ufw
fi
ufw allow OpenSSH
ufw allow 6080/tcp
ufw --force enable

# 13. Enable and start services
print_status "Enabling and starting services..."
systemctl daemon-reload
systemctl enable vncserver@1.service
systemctl enable novncproxy.service
systemctl start vncserver@1.service
systemctl start novncproxy.service

# 14. Final instructions
clear
IP=$(curl -s ifconfig.me)
echo "=================================================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=================================================================="
echo ""
echo -e "${YELLOW}Your VNC Desktop with $DESKTOP_NAME is now ready.${NC}"
echo ""
echo "To connect, open your web browser on your local computer and go to:"
echo ""
echo -e "${GREEN}  http://$IP:6080${NC}"
echo ""
echo "When prompted for a password, use the password you set for the user '$NEW_USER'."
echo ""
echo "Username: $NEW_USER"
echo "Password: [the password you entered]"
echo ""
echo "Enjoy your new desktop!"
echo "=================================================================="
