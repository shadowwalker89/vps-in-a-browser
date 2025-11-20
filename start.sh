#!/bin/bash

# رنگ‌ها برای خروجی بهتر
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}🚀 VPS-in-a-Browser Auto Setup Script${NC}"
echo -e "${GREEN}============================================${NC}"

# بررسی دسترسی روت
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}این اسکریپت باید با دسترسی روت اجرا شود. لطفاً از 'sudo' استفاده کنید.${NC}" 1>&2
   exit 1
fi

# مرحله ۱: بررسی پیش‌نیازها
echo -e "\n${YELLOW}🔎 Checking for prerequisites...${NC}"
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}pm2 not found. Installing pm2 globally...${NC}"
    npm install pm2 -g
else
    echo -e "${GREEN}✅ pm2 is already installed.${NC}"
fi

if ! command -v certbot &> /dev/null; then
    echo -e "${RED}❌ certbot not found. Please install it first:${NC}"
    echo "sudo apt update"
    echo "sudo apt install -y git nodejs npm certbot websockify novnc unzip ufw"
    exit 1
fi

# مرحله ۲: دریافت اطلاعات از کاربر
echo -e "\n${YELLOW}📋 Please provide the following information:${NC}"
read -p "Enter your domain name (e.g., example.com): " DOMAIN
read -p "Enter your email for Let's Encrypt: " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo -e "${RED}❌ Domain and email cannot be empty.${NC}"
    exit 1
fi

# مرحله ۳: دریافت گواهی SSL
echo -e "\n${YELLOW}🔐 Obtaining SSL certificate for ${DOMAIN}...${NC}"
sudo certbot certonly --standalone --non-interactive --agree-tos --email "$EMAIL" -d "$DOMAIN"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to obtain SSL certificate. Please check your domain's A record and ensure port 80 is open.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ SSL certificate obtained successfully!${NC}"

# مرحله ۴: ایجاد فایل پیکربندی pm2
echo -e "\n${YELLOW}⚙️ Creating pm2 configuration file...${NC}"
cat > ecosystem.config.js << EOL
module.exports = {
  apps: [
    {
      name: 'vps-server',
      script: 'server.js',
      env: {
        "DOMAIN": "$DOMAIN",
        "NODE_ENV": "production"
      },
      error_file: './logs/vps-server-error.log',
      out_file: './logs/vps-server-out.log',
      log_file: './logs/vps-server-combined.log',
      time: true
    },
    {
      name: 'websockify',
      script: '/usr/bin/websockify',
      args: '--web=/usr/share/novnc 6080 localhost:5901 --cert=/etc/letsencrypt/live/$DOMAIN/fullchain.pem --key=/etc/letsencrypt/live/$DOMAIN/privkey.pem',
      interpreter: '/usr/bin/python3',
      error_file: './logs/websockify-error.log',
      out_file: './logs/websockify-out.log',
      log_file: './logs/websockify-combined.log',
      time: true
    }
  ]
};
EOL

# ایجاد پوشه لاگ‌ها
mkdir -p logs

# مرحله ۵: اجرای سرویس‌ها با pm2
echo -e "\n${YELLOW}🚀 Starting services with pm2...${NC}"
pm2 start ecosystem.config.js
pm2 save

# مرحله ۶: تنظیم برای اجرای خودکار پس از ری‌استارت
echo -e "\n${YELLOW}🔧 Setting up startup script for pm2...${NC}"
pm2 startup | grep -E '^sudo' | sh # اجرای دستور خروجی pm2 startup

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "🔗 Access your VNC in your browser at:"
echo -e "   ${GREEN}https://${DOMAIN}/${NC}"
echo -e "\n💡 To manage your application, use these commands:"
echo -e "   ${YELLOW}pm2 status${NC}      # View status"
echo -e "   ${YELLOW}pm2 logs${NC}        # View logs"
echo -e "   ${YELLOW}pm2 stop all${NC}    # Stop services"
echo -e "   ${YELLOW}pm2 restart all${NC} # Restart services"
echo -e "${GREEN}============================================${NC}"
