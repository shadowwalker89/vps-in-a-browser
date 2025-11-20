const express = require('express');
const https = require('https');
const fs = require('fs');
const { Server } = require("socket.io");
const path = require('path');

const app = express();
const domain = process.env.DOMAIN;

// --- Configuration & SSL Setup ---
if (!domain) {
    console.error("❌ FATAL ERROR: DOMAIN environment variable not set.");
    console.error("Please run the application using 'npm start' or 'sudo node setup-and-start.js'");
    process.exit(1);
}

const sslOptions = {
    key: fs.readFileSync(`/etc/letsencrypt/live/${domain}/privkey.pem`),
    cert: fs.readFileSync(`/etc/letsencrypt/live/${domain}/fullchain.pem`)
};

const PORT = 443; // Standard HTTPS port

// --- Static Files and Routes ---
app.use(express.static(path.join(__dirname, 'public')));
app.use('/novnc', express.static(path.join(__dirname, 'node_modules/novnc')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'vnc.html'));
});

// --- WebSocket (Socket.IO) Setup ---
const server = https.createServer(sslOptions, app);
const io = new Server(server);

io.on('connection', (socket) => {
    console.log('a user connected');
    socket.on('disconnect', () => {
        console.log('user disconnected');
    });
    // Forward commands from browser to server-side process (if needed)
    socket.on('command', (cmd) => {
        console.log('Received command:', cmd);
        // Example: Execute a shell command (SECURITY RISK: be very careful with this!)
        // const { exec } = require('child_process');
        // exec(cmd, (error, stdout, stderr) => { ... });
    });
});

// --- Server Start ---
server.listen(PORT, '0.0.0.0', () => {
    console.log("\n" + "=".repeat(50));
    console.log("✅ VPS-in-a-Browser is running securely!");
    console.log("=".repeat(50));
    console.log(`🔗 Access your VNC in your browser at:`);
    console.log(`   https://${domain}/vnc.html`);
    console.log("\n💡 Tip: You might see a warning if you use a subdomain (e.g., vps.example.com)");
    console.log("   because the certificate is for the main domain. Ensure certbot covers your subdomain.");
    console.log("=".repeat(50));
});
