#!/bin/bash

# Add global npm binaries to PATH to fix 'pm2 not found' error
export PATH="/usr/local/bin:$PATH"

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}🚀 VPS-in-a-Browser Auto Setup Script${NC}"
echo -e "${GREEN}============================================${NC}"

# Check for root access
if [ "$(id -u)" != "0" ]; then
   echo -e "${RED}This script must be run as root. Please use 'sudo'.${NC}" 1>&2
   exit 1
fi

# Step 1: Check and configure firewall
echo -e "\n${YELLOW}🔥 Checking and configuring firewall...${NC}"
ufw allow 80/tcp > /dev/null 2>&1
ufw allow 443/tcp > /dev/null 2>&1
ufw allow 6080/tcp > /dev/null 2>&1
echo -e "${GREEN}✅ Ports 80, 443, and 6080 are allowed in ufw.${NC}"

# Step 2: Select execution mode
echo -e "\n${YELLOW}Please select the execution mode:${NC}"
echo "1) With domain and HTTPS (Recommended)"
echo "2) Without domain and with IP (HTTP)"
read -p "Enter your choice [1-2]: " mode

# Step 3: Free up port 6080 if in use
echo -e "\n${YELLOW}🔍 Checking if port 6080 is in use...${NC}"
PID_ON_PORT=$(lsof -ti :6080)
if [ -n "$PID_ON_PORT" ]; then
    echo -e "${YELLOW}Port 6080 is in use by PID $PID_ON_PORT. Killing it...${NC}"
    kill -9 $PID_ON_PORT
fi

# Common variables
DOMAIN=""
EMAIL=""

if [ "$mode" == "1" ]; then
    # --- HTTPS Mode ---
    echo -e "\n${YELLOW}📋 Please provide the following information for HTTPS setup:${NC}"
    read -p "Enter your domain name (e.g., example.com): " DOMAIN
    read -p "Enter your email for Let's Encrypt: " EMAIL

    if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
        echo -e "${RED}❌ Domain and email cannot be empty.${NC}"
        exit 1
    fi

    # Step 4: Obtain SSL certificate
    echo -e "\n${YELLOW}🔐 Obtaining SSL certificate for ${DOMAIN}...${NC}"
    certbot certonly --standalone --non-interactive --agree-tos --email "$EMAIL" -d "$DOMAIN"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to obtain SSL certificate. Please check your domain's A record and ensure port 80 is open.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ SSL certificate obtained successfully!${NC}"

    # Step 5: Create pm2 configuration for HTTPS
    echo -e "\n${YELLOW}⚙️ Creating pm2 configuration for HTTPS...${NC}"
    cat > ecosystem.config.js << EOL
module.exports = {
  apps: [
    {
      name: 'vps-server',
      script: 'server.js',
      cwd: '$(pwd)',
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
      cwd: '$(pwd)',
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
    FINAL_URL="https://${DOMAIN}/"

else
    # --- HTTP Mode ---
    echo -e "\n${YELLOW}🌐 Setting up for HTTP access via IP address...${NC}"
    
    # Step 5: Create pm2 configuration for HTTP
    echo -e "\n${YELLOW}⚙️ Creating pm2 configuration for HTTP...${NC}"
    cat > ecosystem.config.js << EOL
module.exports = {
  apps: [
    {
      name: 'websockify-http',
      script: '/usr/bin/websockify',
      cwd: '$(pwd)',
      args: '--web=/usr/share/novnc 6080 localhost:5901',
      interpreter: '/usr/bin/python3',
      error_file: './logs/websockify-error.log',
      out_file: './logs/websockify-out.log',
      log_file: './logs/websockify-combined.log',
      time: true
    }
  ]
};
EOL
    # Get IP for display to user
    SERVER_IP=$(curl -s ifconfig.me)
    FINAL_URL="http://${SERVER_IP}:6080/vnc.html"
fi

# Create logs directory
mkdir -p logs

# Step 6: Check and install npm dependencies
if [ ! -d "node_modules" ]; then
    echo -e "\n${YELLOW}📦 node_modules not found. Running npm install...${NC}"
    npm install
fi

# Step 7: Check and install pm2 if not found
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}pm2 not found. Installing pm2 globally...${NC}"
    npm install pm2 -g
fi

# Step 8: Start services with pm2
echo -e "\n${YELLOW}🚀 Starting services with pm2...${NC}"
pm2 start ecosystem.config.js
pm2 save

# Step 9: Set up to run on server boot
echo -e "\n${YELLOW}🔧 Setting up startup script for pm2...${NC}"
pm2 startup | grep -E '^sudo' | sh

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "🔗 Access your VNC in your browser at:"
echo -e "   ${GREEN}${FINAL_URL}${NC}"
echo -e "\n💡 To manage your application, use these commands:"
echo -e "   ${YELLOW}pm2 status${NC}      # View status"
echo -e "   ${YELLOW}pm2 logs${NC}        # View logs"
echo -e "   ${YELLOW}pm2 stop all${NC}    # Stop services"
echo -e "   ${YELLOW}pm2 restart all${NC} # Restart services"
echo -e "${GREEN}============================================${NC}"
