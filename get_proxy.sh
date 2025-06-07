#!/bin/bash

# Đường dẫn đến file JSON
CONFIG_FILE="/etc/xray/proxy1.json"

# Trường hợp dùng để lưu kết quả
declare -A UNIQUE_URLS

# Đọc từng dòng trong file JSON 
while read -r line; do
    # Trích xuất ip
    IP=$(echo "$line" | grep -oP '"ip": *"\K[^"]+')
    # Trích xuất user
    USER=$(echo "$line" | grep -oP '"user": *"\K[^"]+')
    # Trích xuất pass
    PASS=$(echo "$line" | grep -oP '"pass": *"\K[^"]+')

    # Nếu có đủ thông tin
    if [[ -n "$IP" && -n "$USER" && -n "$PASS" ]]; then
        # Ghép lại thành định dạng socks5
        SOCKS5_URL="socks5://$IP:$USER:$PASS"
        # Lưu kết quả vào mảng
        UNIQUE_URLS["$SOCKS5_URL"]=1
    fi
done &lt; &lt;(jq -c '.[]' "$CONFIG_FILE")  # Sử dụng jq để đọc trong mỗi dòng JSON

# In ra các URL không trùng lặp
for url in "${!UNIQUE_URLS[@]}"; do
    echo "$url"
done
