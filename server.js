const express = require('express');
const https = require('https');
const fs = require('fs');
const path = require('path');

const app = express();
const domain = process.env.DOMAIN;

if (!domain) {
    console.error("❌ FATAL ERROR: DOMAIN environment variable not set.");
    process.exit(1);
}

const sslOptions = {
    key: fs.readFileSync(`/etc/letsencrypt/live/${domain}/privkey.pem`),
    cert: fs.readFileSync(`/etc/letsencrypt/live/${domain}/fullchain.pem`)
};

const PORT = 443;

// --- Static Files and Routes ---
// The main page just redirects to websockify URL
app.get('/', (req, res) => {
    res.redirect(`https://${domain}:6080/vnc.html`);
});

// --- Server Start ---
const server = https.createServer(sslOptions, app);
server.listen(PORT, '0.0.0.0', () => {
    console.log("\n" + "=".repeat(50));
    console.log("✅ VPS-in-a-Browser is running securely!");
    console.log("=".repeat(50));
    console.log(`🔗 Access your VNC in your browser at:`);
    console.log(`   https://${domain}/`);
    console.log("=".repeat(50));
});
