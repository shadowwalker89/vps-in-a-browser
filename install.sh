#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}🖥️  VNC Desktop Environment Installer${NC}"
echo -e "${GREEN}============================================${NC}"

# Check for root access
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root. Please use 'sudo'.${NC}" 1>&2
   exit 1
fi

echo -e "\n${YELLOW}Please select your preferred desktop environment:${NC}"
echo "1) LXDE (Lightweight and fast - Recommended)"
echo "2) XFCE4 (Balanced and popular)"
echo "3) Ubuntu Desktop (GNOME - Full-featured and heavy)"
echo "4) Exit"

read -p "Enter your choice [1-4]: " choice

case $choice in
    1)
        DESKTOP="LXDE"
        PACKAGES="lxde tightvncserver"
        STARTUP_CMD="startlxde"
        ;;
    2)
        DESKTOP="XFCE4"
        PACKAGES="xfce4 xfce4-goodies tightvncserver"
        STARTUP_CMD="startxfce4"
        ;;
    3)
        DESKTOP="Ubuntu Desktop (GNOME)"
        PACKAGES="ubuntu-desktop-minimal vnc4server"
        STARTUP_CMD="gnome-session"
        ;;
    4)
        echo -e "${YELLOW}Installation canceled.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Installation canceled.${NC}"
        exit 1
        ;;
esac

echo -e "\n${YELLOW}You have selected ${DESKTOP}.${NC}"
echo -e "${YELLOW}Installing required packages...${NC}"
apt update
apt install -y $PACKAGES

echo -e "\n${YELLOW}Configuring VNC...${NC}"

# Create xstartup file for the selected desktop
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<EOF
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
 $STARTUP_CMD &
EOF
chmod +x ~/.vnc/xstartup

echo -e "\n${GREEN}✅ Installation of ${DESKTOP} completed successfully.${NC}"
echo -e "${YELLOW}You can now start the VNC server with:${NC}"
echo -e "${GREEN}vncserver :1${NC}"
echo -e "${YELLOW}And stop it with:${NC}"
echo -e "${GREEN}vncserver -kill :1${NC}"
