#!/bin/bash

# Đường dẫn đến file JSON
CONFIG_FILE="/etc/xray/proxy1.json"
TEMP_FILE="/tmp/temp_config.json"

# Lấy từ dòng 2 đến dòng 15 từ file JSON và lưu vào file tạm
sed -n '2,15p' "$CONFIG_FILE" > "$TEMP_FILE"

# Trích xuất listen (IP) và port từ file tạm
IP=$(grep -oP '"listen": *"\K[^"]+' "$TEMP_FILE")
# PORT=$(grep -oP '"port": *"\K[0-9]+' "$TEMP_FILE")
PORT=$(jq -r '.[0].port' "$TEMP_FILE")
# PORT=$(jq -r '.inbounds[].port' "$TEMP_FILE")
# Trích xuất user và pass, loại bỏ trùng lặp và chỉ lấy giá trị đầu tiên của user
USER=$(grep -oP '"user": *"\K[^"]+' "$TEMP_FILE")
PASS=$(grep -oP '"pass": *"\K[^"]+' "$TEMP_FILE")

# Ghép lại thành định dạng socks5
SOCKS5_URL="socks5://$IP:7001:$USER:$PASS"
sed -n '7p' /etc/xray/proxy1.json
echo "SOCKS5 URL: $SOCKS5_URL"
# Xóa file tạm sau khi sử dụng
rm "$TEMP_FILE"
