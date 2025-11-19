> # 🌐 VPS in a Browser
>
> <div align="center">
>
> [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
> [![Shell Script](https://img.shields.io/badge/Shell_Script-121021?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
> [![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
>
> *A one-script installer to turn your low-resource VPS into a lightweight, graphical desktop accessible directly from your web browser.*
>
> </div>
> ---
> <details>
> <summary><strong>🇺🇸 English Instructions</strong></summary>
>
> ## 🚀 Quick Start (One-Click Install)
>
> Run this single command on your fresh Ubuntu server (as `root` or with `sudo`):
>
> ```bash
> bash <(curl -s https://raw.githubusercontent.com/shadowwalker89/vps-in-a-browser/refs/heads/main/install.sh)
> ```
> That's it! The script will guide you through the rest.
>
> ---
>
> ## 📖 Step-by-Step Guide
>
> ### 1. Connect to Your Server
>
> Open your terminal (SSH client) and connect to your server:
> ```bash
> ssh root@YOUR_SERVER_IP
> ```
>
> ### 2. Run the Installer
>
> Copy and paste the one-click install command from above and press Enter.
>
> ### 3. Follow Prompts
>
> The script will ask you for:
> * **Desktop Environment:** Choose between `XFCE` (balanced), `LXQt` (lightweight), or `Openbox` (ultra-lightweight).
> * **Username:** A new user for the desktop.
> * **Password:** A password for the new user.
>
> The installation will take a few minutes.
>
> ### 4. Connect to Your New Desktop
>
> Once the script finishes, open your web browser (Firefox, Chrome, etc.) and navigate to:
> ```
> http://YOUR_SERVER_IP:6080
> ```
> Enter the username and password you created. Enjoy your new desktop!
>
> ---
>
> ## ⚡ Performance Tips
>
> For the best experience on a low-resource VPS:
> * Choose **LXQt** or **Openbox** during installation for a lighter desktop.
> * When running Chrome, use these flags for better performance:
> ```bash
> google-chrome-stable --no-sandbox --disable-gpu --disable-dev-shm-usage
> ```
>
> ---
>
> ## 🛠️ Troubleshooting
>
> * **Connection timed out:** Ensure port `6080` is open in your firewall. The script tries to do this automatically.
> * **Desktop is slow:** This is normal on a 1GB RAM VPS. Keep browser tabs to a minimum and choose a lighter desktop environment.
>
> </details>
>
> <details>
> <summary><strong>🇮🇷 راهنمای فارسی</strong></summary>
>
> <div dir="rtl" lang="fa">
>
> ## 🚀 شروع سریع (نصب با یک کلیک)
>
> این دستور واحد را روی سرور اوبونتو خود (با کاربر `root` یا با دسترسی `sudo`) اجرا کنید:
>
> ```bash
> bash <(curl -s https://raw.githubusercontent.com/shadowwalker89/vps-in-a-browser/refs/heads/main/install.sh)
> ```
> همین! بقیه مراحل توسط اسکریپت راهنمایی می‌شود.
>
> ---
>
> ## 📖 راهنمای گام به گام
>
> ### ۱. به سرور خود متصل شوید
>
> ترمینال خود (کلاینت SSH) را باز کرده و به سرور متصل شوید:
> ```bash
> ssh root@IP_سرور_شما
> ```
>
> ### ۲. نصب‌کننده را اجرا کنید
>
> دستور نصب یک‌کلیکی را از بالا کپی کرده و در ترمینال خود Paste کنید و Enter را بزنید.
>
> ### ۳. دستورالعمل‌ها را دنبال کنید
>
> اسکریپت از شما موارد زیر را می‌پرسد:
> * **محیط دسکتاپ:** بین `XFCE` (متعادل)، `LXQt` (سبک) یا `Openbox` (فوق‌العاده سبک) یکی را انتخاب کنید.
> * **نام کاربری:** یک نام کاربری جدید برای دسکتاپ.
> * **رمز عبور:** یک رمز عبور برای کاربر جدید.
>
> نصب ممکن است چند دقیقه طول بکشد.
>
> ### ۴. به دسکتاپ جدید خود متصل شوید
>
> پس از اتمام اسکریپت، مرورگر وب خود (فایرفاکس، کروم و...) را باز کرده و به آدرس زیر بروید:
> ```
> http://IP_سرور_شما:6080
> ```
> نام کاربری و رمز عبوری که ساختید را وارد کنید. از دسکتاپ جدید خود لذت ببرید!
>
> ---
>
> ## ⚡ نکات بهینه‌سازی
>
> برای بهترین تجربه روی یک VPS کم‌مصرف:
> * در حین نصب، **LXQt** یا **Openbox** را برای یک دسکتاپ سبک‌تر انتخاب کنید.
> * هنگام اجرای کروم، از این پرچم‌ها برای عملکرد بهتر استفاده کنید:
> ```bash
> google-chrome-stable --no-sandbox --disable-gpu --disable-dev-shm-usage
> ```
>
> ---
>
> ## 🛠️ عیب‌یابی
>
> * **Connection timed out:** مطمئن شوید که پورت `6080` در فایروال شما باز است. اسکریپت به طور خودکار این کار را انجام می‌دهد.
> * **دسکتاپ کند است:** این موضوع روی یک VPS با ۱ گیگابایت رم طبیعی است. تعداد تب‌های مرورگر را کم نگه دارید و یک محیط دسکتاپ سبک‌تر انتخاب کنید.
>
> </div>
>
> </details>
>
> <div align="center">
>
> **Made with ❤️ for the community**
>
> </div>
>
