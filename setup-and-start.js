const readline = require('readline');
const { execSync } = require('child_process');
const fs = require('fs');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log("=".repeat(60));
console.log("🚀 VPS-in-a-Browser HTTPS Setup");
console.log("=".repeat(60));

// Step 1: Show DNS Guide
console.log("\n📋 STEP 1: DNS Configuration Guide");
console.log("-".repeat(40));
console.log("Before we start, you need to point your domain to this server's IP address.");
console.log("Please go to your domain registrar's DNS settings and create an 'A Record':");
console.log("\n    Type: A");
console.log("    Name: @ (or your subdomain, e.g., 'vps')");
console.log("    Value: [YOUR_SERVER_IP_ADDRESS]");
console.log("    TTL: 300 (or as low as possible)\n");
console.log("⚠️  Note: DNS changes can take a few minutes to propagate.");


// Step 2: Prompt for Domain and Email
const question1 = () => {
  return new Promise((resolve) => {
    rl.question('Enter your domain name (e.g., example.com): ', (domain) => {
      resolve(domain.trim());
    });
  });
};

const question2 = () => {
  return new Promise((resolve) => {
    rl.question('Enter your email for Let\'s Encrypt (for urgent renewal notices): ', (email) => {
      resolve(email.trim());
    });
  });
};

// Step 3: Check for Certbot and run it
const setupSSL = (domain, email) => {
  console.log("\n🔐 STEP 2: Obtaining SSL Certificate");
  console.log("-".repeat(40));
  
  try {
    // Check if certbot is installed
    execSync('which certbot', { stdio: 'ignore' });
  } catch (error) {
    console.error("❌ 'certbot' is not installed.");
    console.log("Please install it first. On Ubuntu/Debian, you can run:");
    console.log("  sudo apt update");
    console.log("  sudo apt install certbot");
    process.exit(1);
  }

  try {
    console.log(`Requesting certificate for ${domain}...`);
    // Using standalone mode, which temporarily runs a webserver on port 80
    execSync(`sudo certbot certonly --standalone --non-interactive --agree-tos --email ${email} -d ${domain}`, { stdio: 'inherit' });
    console.log("✅ SSL certificate obtained successfully!");
  } catch (error) {
    console.error("\n❌ Failed to obtain SSL certificate.");
    console.error("Please ensure:");
    console.error("1. Your domain's A record is correctly pointing to this server's IP.");
    console.error("2. Port 80 is not blocked by a firewall.");
    console.error("3. No other service (like Apache or Nginx) is using port 80.");
    process.exit(1);
  }
};

// Step 4: Start the main server
const startServer = (domain) => {
  console.log("\n🌟 STEP 3: Starting the VPS Server");
  console.log("-".repeat(40));
  try {
    console.log(`Starting server on https://${domain}`);
    // Pass the domain as an environment variable to server.js
    // We use 'inherit' to show the server's logs directly in the console
    execSync(`sudo DOMAIN=${domain} node server.js`, { stdio: 'inherit' });
  } catch (error) {
    console.error("\n❌ Failed to start the server.");
    process.exit(1);
  }
};

// Main execution flow
const main = async () => {
  const domain = await question1();
  if (!domain) {
    console.error("❌ Domain cannot be empty.");
    rl.close();
    return;
  }
  const email = await question2();
  if (!email || !email.includes('@')) {
    console.error("❌ Please enter a valid email address.");
    rl.close();
    return;
  }
  rl.close();

  setupSSL(domain, email);
  startServer(domain);
};

main();
