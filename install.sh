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
   echo -e "${RED}این اسکریپت باید با دسترسی روت اجرا شود. لطفاً از 'sudo' استفاده کنید.${NC}" 1>&2
   exit 1
fi

echo -e "\n${YELLOW}لطفاً محیط دسکتاپ مورد نظر خود را انتخاب کنید:${NC}"
echo "1) LXDE (سبک و سریع - پیشنهادی)"
echo "2) XFCE4 (متعادل و محبوب)"
echo "3) Ubuntu Desktop (GNOME - کامل و سنگین)"
echo "4) خروج"

read -p "گزینه خود را وارد کنید [1-4]: " choice

case $choice in
    1)
        DESKTOP="LXDE"
        PACKAGES="lxde tightvncserver chromium-browser"
        STARTUP_CMD="startlxde"
        ;;
    2)
        DESKTOP="XFCE4"
        PACKAGES="xfce4 xfce4-goodies tightvncserver chromium-browser"
        STARTUP_CMD="startxfce4"
        ;;
    3)
        DESKTOP="Ubuntu Desktop (GNOME)"
        PACKAGES="ubuntu-desktop-minimal vnc4server chromium-browser"
        STARTUP_CMD="gnome-session"
        ;;
    4)
        echo -e "${YELLOW}نصب لغو شد.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}گزینه نامعتبر است. نصب لغو شد.${NC}"
        exit 1
        ;;
esac

echo -e "\n${YELLOW}شما ${DESKTOP} را انتخاب کردید.${NC}"
echo -e "${YELLOW}در حال نصب پکیج‌های مورد نیاز...${NC}"
apt update
apt install -y $PACKAGES

echo -e "\n${YELLOW}🎨 Applying lightweight desktop configurations...${NC}"

# Create optimized xstartup file for the selected desktop
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<EOF
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Apply performance optimizations based on desktop choice
case "$choice" in
    1) # LXDE
        export GTK_THEME=Adwaita-dark
        ;;
    2) # XFCE4
        xfconf-query -c xfce4-session -p /xfwm4/general/use_compositing -s false &
        ;;
    3) # GNOME
        gsettings set org.gnome.desktop.interface enable-animations false &
        gsettings set org.gnome.shell disable-user-extensions true &
        ;;
esac

$STARTUP_CMD &
EOF
chmod +x ~/.vnc/xstartup

echo -e "\n${GREEN}✅ Installation of ${DESKTOP} completed successfully.${NC}"
echo -e "${GREEN}✅ Desktop environment optimized for low resource usage.${NC}"
echo -e "${GREEN}✅ Chromium browser has been installed.${NC}"
echo -e "\n${YELLOW}اکنون می‌توانید سرور VNC را با دستور زیر اجرا کنید:${NC}"
echo -e "${GREEN}vncserver :1${NC}"
echo -e "${YELLOW}و آن را با دستور زیر متوقف کنید:${NC}"
echo -e "${GREEN}vncserver -kill :1${NC}"
