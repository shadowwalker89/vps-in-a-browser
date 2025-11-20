# VPS-in-a-Browser

Run a lightweight VPS-like environment with a graphical desktop, accessible directly and securely through your web browser.

![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white)
![Let's Encrypt](https://img.shields.io/badge/Let's%20Encrypt-003A70?style=for-the-badge&logo=letsencrypt&logoColor=white)
![noVNC](https://img.shields.io/badge/noVNC-000000?style=for-the-badge&logo=vnc&logoColor=white)

## ✨ Features

-   **Easy HTTPS Setup**: Automatically obtains a free SSL certificate from Let's Encrypt.
-   **One-Command Deployment**: A single script handles everything from setup to running the services in the background.
-   **Persistent Services**: Uses `pm2` to ensure the application is always running and survives server reboots.
-   **Lightweight Desktop**: Installs a minimal LXDE desktop environment for optimal performance.
-   **Secure Access**: All traffic is encrypted and routed securely.

## 🚀 Quick Start (3 Steps)

This guide assumes you are using a fresh Ubuntu/Debian server with `sudo` access.

### Step 1: Install Dependencies

Install Node.js, npm, and other required packages.

```bash
sudo apt update
sudo apt install -y git nodejs npm certbot websockify novnc unzip ufw
```
Step 2: Install VNC Desktop 

This script installs a lightweight LXDE desktop and a VNC server. 

```bash
git clone https://github.com/shadowwalker89/vps-in-a-browser.git
cd vps-in-a-browser
chmod +x install.sh
sudo ./install.sh
```
Follow the on-screen prompts to set a VNC password. 
Step 3: Run the Application 

This single command will guide you through the final setup, obtain an SSL certificate, and start the services in the background. 

```bash
sudo ./start.sh
```
he script will ask for your domain name and an email address. Once finished, it will provide you with the final URL to access your VNC session. 
🛠️ Managing the Application 

The application is managed by pm2. Here are some useful commands: 

     pm2 status: See the status of the running applications.
     pm2 logs: View the real-time logs for all applications.
     pm2 logs vps-server: View logs only for the main server.
     pm2 stop all: Stop all applications.
     pm2 restart all: Restart all applications.
     pm2 delete all: Remove all applications from the pm2 process list.
     

🤝 Contributing 

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. 
📄 License 

This project is licensed under the MIT License. 
