#!/bin/bash

# Đường dẫn đến file JSON
CONFIG_FILE="/etc/xray/proxy1.json"

# Trường hợp dùng để lưu kết quả
declare -A UNIQUE_URLS

# Duyệt qua tất cả các inbound trong file JSON
jq -c '.inbounds[]' "$CONFIG_FILE" | while read -r inbound; do
    # Lấy địa chỉ listen và port từ đối tượng inbound
    LISTEN=$(echo "$inbound" | jq -r '.listen')
    PORT=$(echo "$inbound" | jq -r '.port')
    
    # Lấy danh sách tài khoản từ trường "accounts" nếu có
    echo "$inbound" | jq -c '.settings.accounts[]?' | while read -r account; do
        USER=$(echo "$account" | jq -r '.user')
        PASS=$(echo "$account" | jq -r '.pass')

        # Kiểm tra nếu có đủ thông tin
        if [[ -n "$LISTEN" && -n "$PORT" && -n "$USER" && -n "$PASS" ]]; then
            # Ghép lại thành định dạng socks5
            SOCKS5_URL="socks5://$LISTEN:$PORT:$USER:$PASS"
            
            # Lưu kết quả vào mảng để loại bỏ trùng lặp
            UNIQUE_URLS["$SOCKS5_URL"]=1
        fi
    done
done

# In ra các URL không trùng lặp
for url in "${!UNIQUE_URLS[@]}"; do
    echo "$url"
done
